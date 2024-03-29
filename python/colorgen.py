import argparse
import csv
import math

import numpy as np
from matplotlib import pyplot as plt
from scipy import signal


class Colorgen:
    def __init__(self, ntsc=False, contrast=1.0, saturation=1.0):
        self.ntsc = ntsc
        if ntsc:
            # color burst frequency
            self.fsc = 315 / 88 * 1e6
            # CPU clock frequency
            self.phi0 = 2 * self.fsc / 7
            self.pix_per_line = 520
            # pixels between start of hsync and somewhere stable in color burst
            self.burst_pix = 50
        else:
            self.fsc = 4433618.75
            self.phi0 = 2 * self.fsc / 9
            self.pix_per_line = 504
            self.burst_pix = 58

        # length of pixel in seconds
        self.pix = 1 / (8 * self.phi0)

        self.burst_cycles = 9

        # pixel at which to measure sync depth
        self.sync_pix = 18

        # pixels between start of hsync and first black bar
        self.black_pix = 160

        self.ncolors = 16

        self.pix_per_bar = 16

        # weights for yuv-to-rgb conversion
        self.wr = 0.299
        self.wg = 0.587
        self.wb = 0.114

        self.contrast = contrast
        self.saturation = saturation

    def lowpass(self, s):
        # This filter appears to yield the best results.
        filter = signal.butter(
            5, self.fsc / 2, fs=1 / self.xincr, output="sos"
        )
        return signal.sosfilt(filter, s)

    # Compute Y, U and V values from sample data
    #
    # If we have only one channel, assume the channel contains a composite
    # signal. Otherwise, we have luma and chroma in separate channels,
    # and we can skip the Y signal extraction
    #
    def calc_yuv(self, offset):
        c = np.multiply(
            self.c_data, 2 * np.cos(2 * np.pi * (self.fsc * self.t) + offset)
        )
        s = np.multiply(
            self.c_data, 2 * np.sin(2 * np.pi * (self.fsc * self.t) + offset)
        )
        y = self.y_data
        u = self.lowpass(s)
        v = self.lowpass(c)
        self.y_signal = y
        self.u_signal = u
        self.v_signal = v

    # convert pixel offset to offset in the sample data
    def offset(self, p):
        return int(round(self.pix * p / self.xincr) + len(self.scope_data) / 2)

    # Take a sample of the YUV data around pixel p
    # The left edge of pixel 0 is assumed to coincide with the
    # start of the horizontal sync. (The trigger point in the oscilloscope.)
    # flip: change sign of V (PAL quirk)
    def sample(self, p, flip=False, cycles=2):

        samples = round(cycles / (self.fsc * self.xincr))

        o = min(max(self.offset(p), 0), self.y_signal.size - 1)
        p = min(o + samples - 1, self.y_signal.size - 1)
        if o < p:
            y_avg = np.average(self.y_signal[o:p])
            y_std = np.std(self.y_signal[o:p])
            u_avg = np.average(self.u_signal[o:p])
            u_std = np.std(self.u_signal[o:p])
            v_avg = np.average(self.v_signal[o:p])
            if flip:
                v_avg = -v_avg
            v_std = np.std(self.v_signal[o:p])
            a = abs(u_avg + v_avg * 1j)
            phi = math.atan2(v_avg, u_avg)
        else:
            nan = float("nan")
            y_avg = nan
            y_std = nan
            u_avg = nan
            u_std = nan
            v_avg = nan
            v_std = nan
            a = nan
            phi = nan
        return {
            "y_avg": y_avg,
            "y_std": y_std,
            "u_avg": u_avg,
            "u_std": u_std,
            "v_avg": v_avg,
            "v_std": v_std,
            "a": a,
            "phi": phi,
        }

    # Average out two successive lines (comb filter)
    @staticmethod
    def avgsample(sample1, sample2):
        y_avg = (sample1["y_avg"] + sample2["y_avg"]) / 2
        y_std = (sample1["y_std"] + sample2["y_std"]) / 2
        u_avg = (sample1["u_avg"] + sample2["u_avg"]) / 2
        u_std = (sample1["u_std"] + sample2["u_std"]) / 2
        v_avg = (sample1["v_avg"] + sample2["v_avg"]) / 2
        v_std = (sample1["v_std"] + sample2["v_std"]) / 2
        a = abs(u_avg + v_avg * 1j)
        phi = math.atan2(v_avg, u_avg)
        return {
            "y_avg": y_avg,
            "y_std": y_std,
            "u_avg": u_avg,
            "u_std": u_std,
            "v_avg": v_avg,
            "v_std": v_std,
            "a": a,
            "phi": phi,
        }

    # Convert value between 0 and 1 into a color brightness from 0 to 255
    # This method also returns whether the input actually fitted in that
    # range.
    @staticmethod
    def norm(a, offset=0, factor=255):
        if math.isnan(a):
            r = 0
            ok = False
        else:
            r = round(offset + factor * a)
            ok = True
            if r < 0:
                r = 0
                ok = False
            if r > 255:
                r = 255
                ok = False
        return r, ok

    def weighted_yuv_to_rgb(self, y, u, v, wu, wv):
        r = y + (1 / wv) * v
        g = y - (self.wb / (wu * self.wg)) * u - (self.wr / (wv * self.wg)) * v
        b = y + (1 / wu) * u
        return (r, g, b)

    def rgb(self, y, u, v):
        ri, gi, bi = self.weighted_yuv_to_rgb(y, u, v, 0.492, 0.877)
        r, rok = self.norm(ri)
        g, gok = self.norm(gi)
        b, bok = self.norm(bi)
        return r, g, b, rok and gok and bok

    def ycbcr(self, y, u, v):
        yo, yok = self.norm(y, 16, 219)
        cb, cbok = self.norm(u * 0.564 / 0.492, 128, 224)
        cr, crok = self.norm(v * 0.713 / 0.877, 128, 224)
        return yo, cb, cr, yok and cbok and crok

    def printsample(self, prefix, sample):
        if self.ntsc:
            blkref = 4.0 / 14.0
            cref = 0.2
        else:
            blkref = 0.3
            cref = 0.15
        y = self.contrast * (
            blkref
            * (sample["y_avg"] - self.black_level)
            / self.sync_depth
            / (1 - blkref)
        )
        # FIXME this is incorrect for NTSC
        if self.burst_amplitude:
            u = (
                self.saturation
                * cref
                * sample["u_avg"]
                / self.burst_amplitude
                / (1 - blkref)
            )
            v = (
                self.saturation
                * cref
                * sample["v_avg"]
                / self.burst_amplitude
                / (1 - blkref)
            )
        else:
            u = 0
            v = 0
        # peak-to-peak color voltage adjusted for color burst
        vpp = 2 * abs(u + v * 1j) * (1 - blkref)
        r, g, b, ok = self.rgb(y, u, v)
        if ok:
            s = ""
        else:
            s = "X"
        phi = 180 * sample["phi"] / math.pi
        if vpp < 0.03:
            phi = float("NaN")
        y2, cb, cr, ycbcrok = self.ycbcr(y, u, v)
        print(
            f"{prefix:10}  "
            f"{sample['y_avg']:5.2f} "
            f"{sample['y_std']:5.2f}  "
            f"{sample['u_avg']:5.2f} "
            f"{sample['u_std']:5.2f}  "
            f"{sample['v_avg']:5.2f} "
            f"{sample['v_std']:5.2f} "
            f"{sample['a']:5.2f}  "
            f"ycbcr: {y2:3d} {cb:3d} {cr:3d} "
            f"rgb: {r:02x}{g:02x}{b:02x} "
            f"vpp: {vpp:4.2f} "
            f"angle: {phi:4.0f} {s}"
        )

    # Read samples and compute sync level and color phase.
    #
    # Phase detection is done in two stages; we first sample using a
    # fixed color carrier, then inspect the color burst for two successive
    # lines. From these values we can obtain the proper color carrier.
    # Finally we recalculate the U and V values using the adjusted carrier.
    def process(self, file, u64, vic20, no_chroma_agc):

        self.vic20 = vic20

        if u64:
            self.burst_pix = 52
            self.burst_cycles = 5
            self.black_pix = 162

        if vic20:
            if self.ntsc:
                self.pix = 7 / (8 * self.fsc)
                self.pix_per_line = 260
                self.black_pix = 50
            else:
                self.pix = 1 / self.fsc
                self.pix_per_line = 284
                self.black_pix = 64
            self.burst_pix = 28
            self.sync_pix = 8
            self.pix_per_bar = 12

        with open(file) as f:
            # Some RIGOL-specific bits here.
            # CSV exports have two header lines that indicate the
            # channels captured and the time units.
            # We read these two lines first, then feed the rest into
            # numpy.loadtxt
            reader = csv.reader(f)
            l1 = next(reader)
            d = dict(zip(l1, range(len(l1))))
            if "CH2" in d:
                self.channels = 2
                cols = (d["X"], d["CH1"], d["CH2"])
            else:
                self.channels = 1
                cols = (d["X"], d["CH1"])
            l2 = next(reader)
            xstart = float(l2[d["Start"]])
            self.xincr = float(l2[d["Increment"]])
            self.scope_data = np.loadtxt(f, delimiter=",", usecols=cols)

        if self.channels == 2:
            # luma and color in separate channels
            self.y_data = self.scope_data[:, 1]
            self.c_data = self.scope_data[:, 2]
        else:
            # composite video
            self.y_data = self.lowpass(self.scope_data[:, 1])
            self.c_data = self.scope_data[:, 1] - self.y_data

        self.t = np.linspace(
            xstart,
            xstart + len(self.scope_data) * self.xincr,
            len(self.scope_data),
            False,
        )

        self.calc_yuv(0)

        burst1 = self.sample(
            self.burst_pix - self.pix_per_line, cycles=self.burst_cycles
        )
        burst2 = self.sample(self.burst_pix, cycles=self.burst_cycles)

        if self.ntsc:
            # Take average of color burst angles, then add 180 degrees
            adjustment = (burst1["phi"] + burst2["phi"]) / 2 + math.pi
        else:
            # add burst1 and burst2 sections of unit circle.
            # This will make the adjusted angles exact opposite of each other

            adjustment = math.atan2(
                -math.sin(burst1["phi"]) - math.sin(burst2["phi"]),
                -math.cos(burst1["phi"]) - math.cos(burst2["phi"]),
            )
            # alternatively, just add the (u, v) vectors
            # (should be the same ideally)
            # adjustment = math.atan2(
            #     -burst1["v_avg"] - burst2["v_avg"],
            #     -burst1["u_avg"] - burst2["u_avg"],
            # )

        # re-apply filter with adjusted offset so that color burst is
        # more or less at -135 and +135 degrees

        self.calc_yuv(adjustment)

        self.sync = self.sample(self.sync_pix)
        # re-sample burst
        self.burst1 = self.sample(
            self.burst_pix - self.pix_per_line, cycles=self.burst_cycles
        )
        self.burst2 = self.sample(self.burst_pix, cycles=self.burst_cycles)

        sync_level = self.sync["y_avg"]
        self.black_level = (self.burst1["y_avg"] + self.burst2["y_avg"]) / 2
        self.sync_depth = self.black_level - sync_level
        if no_chroma_agc:
            self.burst_amplitude = 0.15
        else:
            self.burst_amplitude = (self.burst1["a"] + self.burst2["a"]) / 2
        if self.burst_amplitude < 0.04:
            print("color burst amplitude below threshold")
            self.y_data = self.scope_data[:, 1]
            self.c_data = np.zeros(len(self.scope_data))
            self.burst_amplitude = 0
            self.calc_yuv(0)

    def print(self):
        self.printsample("sync", self.sync)
        self.printsample("burst_L", self.burst1)
        self.printsample("burst_R", self.burst2)

        left_flip = self.burst1["v_avg"] < 0

        for color in range(self.ncolors):
            p = self.black_pix + self.pix_per_bar * color + 5
            if self.ntsc:
                left_sample = self.sample(p - self.pix_per_line, False)
                right_sample = self.sample(p, False)
            else:
                if left_flip:
                    left_sample = self.sample(p - self.pix_per_line, True)
                    right_sample = self.sample(p, False)
                else:
                    left_sample = self.sample(p - self.pix_per_line, False)
                    right_sample = self.sample(p, True)
            comb_sample = self.avgsample(left_sample, right_sample)
            self.printsample(f"{color:02d}_L", left_sample)
            self.printsample(f"{color:02d}_R", right_sample)
            self.printsample(f"{color:02d}_c", comb_sample)

    def plot(self):
        fig = plt.figure()
        ax = fig.add_subplot()
        x = self.t / self.pix
        ax.plot(x, self.c_data, label="c", color="green")
        ax.plot(x, self.y_signal, label="y", color="grey")
        ax.plot(x, self.u_signal, label="u", color="blue")
        ax.plot(x, self.v_signal, label="v", color="red")
        ax.legend()
        plt.show()


def main():
    argp = argparse.ArgumentParser()
    argp.add_argument("-f", "--file", required=True)
    argp.add_argument("--u64", action="store_true")
    argp.add_argument("--vic20", action="store_true")
    argp.add_argument("--no-chroma-agc", action="store_true")
    argp.add_argument("--ntsc", action="store_true")
    argp.add_argument("--contrast", type=float, default=1.0)
    argp.add_argument("--saturation", type=float, default=1.0)
    args = argp.parse_args()
    colorgen = Colorgen(
        ntsc=args.ntsc, contrast=args.contrast, saturation=args.saturation
    )
    colorgen.process(args.file, args.u64, args.vic20, args.no_chroma_agc)
    colorgen.print()
    colorgen.plot()


if __name__ == "__main__":
    # execute only if run as a script
    main()
