import argparse
import csv
import math

import numpy as np
from matplotlib import pyplot as plt
from scipy import signal


class Colorgen:

    # PAL color burst frequency
    fsc = 4433618.75

    # CPU clock frequency
    phi0 = 2 * fsc / 9

    # length of pixel in seconds
    pix = 1 / (8 * phi0)

    # weights for yuv-to-rgb conversion
    wr = 0.299
    wg = 0.587
    wb = 0.114

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

        o = self.offset(p)
        y_avg = np.average(self.y_signal[o : o + samples - 1])
        y_std = np.std(self.y_signal[o : o + samples - 1])
        u_avg = np.average(self.u_signal[o : o + samples - 1])
        u_std = np.std(self.u_signal[o : o + samples - 1])
        v_avg = np.average(self.v_signal[o : o + samples - 1])
        if flip:
            v_avg = -v_avg
        v_std = np.std(self.v_signal[o : o + samples - 1])
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
        r = round(offset + factor * a)
        ok = True
        if r < 0:
            r = 0
            ok = False
        if r > 255:
            r = 255
            ok = False
        return r, ok

    @classmethod
    def weighted_yuv_to_rgb(cls, y, u, v, wu, wv):
        r = y + (1 / wv) * v
        g = y - (cls.wb / (wu * cls.wg)) * u - (cls.wr / (wv * cls.wg)) * v
        b = y + (1 / wu) * u
        return (r, g, b)

    @classmethod
    def rgb(cls, y, u, v):
        ri, gi, bi = cls.weighted_yuv_to_rgb(y, u, v, 0.492, 0.877)
        r, rok = cls.norm(ri)
        g, gok = cls.norm(gi)
        b, bok = cls.norm(bi)
        return r, g, b, rok and gok and bok

    @classmethod
    def ycbcr(cls, y, u, v):
        yo, yok = cls.norm(y, 16, 219)
        cb, cbok = cls.norm(u * 0.564 / 0.492, 128, 224)
        cr, crok = cls.norm(v * 0.713 / 0.877, 128, 224)
        return yo, cb, cr, yok and cbok and crok

    def printsample(self, prefix, sample):
        y = 0.3 * (sample["y_avg"] - self.black_level) / self.sync_depth / 0.7
        if self.burst_amplitude:
            u = 0.15 * sample["u_avg"] / self.burst_amplitude / 0.7
            v = 0.15 * sample["v_avg"] / self.burst_amplitude / 0.7
        else:
            u = 0
            v = 0
        r, g, b, ok = self.rgb(y, u, v)
        if ok:
            s = ""
        else:
            s = "X"
        phi = 180 * sample["phi"] / math.pi
        # peak-to-peak color voltage adjusted for .3V color burst
        vpp = 2 * abs(u + v * 1j) * .7
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
            f"vpp: {vpp:.2f} "
            f"angle: {phi:4.0f} {s}"
        )

    # Read samples and compute sync level and color phase.
    #
    # Phase detection is done in two stages; we first sample using a
    # fixed color carrier, then inspect the color burst for two successive
    # lines. From these values we can obtain the proper color carrier.
    # Finally we recalculate the U and V values using the adjusted carrier.
    def process(self, file, u64):

        self.u64 = u64

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

        # pixels between start of hsync and somewhere stable in color burst
        burst_pix = 58
        burst_cycles = 9
        if u64:
            burst_pix = 52
            burst_cycles = 5

        burst1 = self.sample(burst_pix - 504, cycles=burst_cycles)
        burst2 = self.sample(burst_pix, cycles=burst_cycles)

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

        self.sync = self.sample(18)
        # re-sample burst
        self.burst1 = self.sample(burst_pix - 504, cycles=burst_cycles)
        self.burst2 = self.sample(burst_pix, cycles=burst_cycles)

        sync_level = self.sync["y_avg"]
        self.black_level = (self.burst1["y_avg"] + self.burst2["y_avg"]) / 2
        self.sync_depth = self.black_level - sync_level
        self.burst_amplitude = (self.burst1["a"] + self.burst2["a"]) / 2
        if self.burst_amplitude < 0.04:
            print("color burst amplitude below threshold")
            self.y_data = self.scope_data[:, 1]
            self.c_data = np.zeros(len(self.scope_data))
            self.burst_amplitude = 0
            self.calc_yuv(0)

    def print(self):
        self.printsample("sync", self.sync)
        self.printsample("burst-1", self.burst1)
        self.printsample("burst-2", self.burst2)

        left_flip = self.burst1["v_avg"] < 0

        # pixels between start of hsync and first black bar
        black_pix = 160
        if self.u64:
            black_pix = 162

        for color in range(16):
            p = black_pix + 16 * color + 5
            if left_flip:
                flipped_sample = self.sample(p - 504, True)
                unflipped_sample = self.sample(p, False)
            else:
                flipped_sample = self.sample(p, True)
                unflipped_sample = self.sample(p - 504, False)
            comb_sample = self.avgsample(unflipped_sample, flipped_sample)
            # On C64 flipped lines are always at even rasters
            self.printsample(f"{color:02d}_even", flipped_sample)
            self.printsample(f"{color:02d}_odd", unflipped_sample)
            self.printsample(f"{color:02d}_comb", comb_sample)

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
    args = argp.parse_args()
    colorgen = Colorgen()
    colorgen.process(args.file, args.u64)
    colorgen.print()
    colorgen.plot()


if __name__ == "__main__":
    # execute only if run as a script
    main()
