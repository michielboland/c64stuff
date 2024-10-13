import argparse
import math


def printit(bignum, smallnum):
    b1 = bignum & 0xFF
    b2 = (bignum >> 8) & 0xFF
    b3 = (bignum >> 16) & 0xFF
    print(f"  .byte {b1:3d}, {b2:3d}, {b3:3d}, {smallnum:3d}")


def main():
    argp = argparse.ArgumentParser()
    argp.add_argument("--ntsc", action="store_true")
    args = argp.parse_args()

    if args.ntsc:
        f = 11250000 / 11
    else:
        f = 17734475 / 18
    cycles = round(6 * f)
    c = math.log(2048) / cycles

    rounded_total = 0

    printit(round(f), 15)

    for y in range(2, 2049):
        total = math.log(y) / c
        increment = round(total - rounded_total)
        rounded_total += increment
        printit(increment, 47)


if __name__ == "__main__":
    # execute only if run as a script
    main()