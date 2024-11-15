import argparse
import math


def printit(bignum, extra_cycles):
    adjusted = bignum - extra_cycles
    assert adjusted > 0
    b1 = adjusted & 0xFF
    b2 = (adjusted >> 8) & 0xFF
    b3 = (adjusted >> 16) & 0xFF
    print(
        f"  .byte {b1:3d}, {b2:3d}, {b3:3d}, 0 ; {bignum}"
        f" - {extra_cycles}"
    )


def main():
    argp = argparse.ArgumentParser()
    argp.add_argument("--ntsc", action="store_true")
    argp.add_argument("--duration", type=int, default=11)
    argp.add_argument("--extra-cycles", type=int, default=211)
    args = argp.parse_args()

    if args.ntsc:
        f = 11250000 / 11
    else:
        f = 17734475 / 18
    cycles = round(args.duration * f)
    c = math.log(2048) / cycles

    rounded_total = 0

    printit(round(f), args.extra_cycles)

    for y in range(2, 2049):
        total = math.log(y) / c
        increment = round(total - rounded_total)
        rounded_total += increment
        printit(increment, args.extra_cycles)


if __name__ == "__main__":
    # execute only if run as a script
    main()
