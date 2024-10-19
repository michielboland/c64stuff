import argparse
import math


extra_cycles = 224
filter_off_value = 15
filter_on_value = 47


def printit(bignum, smallnum):
    adjusted = bignum - extra_cycles
    assert adjusted > 0
    b1 = adjusted & 0xFF
    b2 = (adjusted >> 8) & 0xFF
    b3 = (adjusted >> 16) & 0xFF
    print(
        f"  .byte {b1:3d}, {b2:3d}, {b3:3d}, {smallnum:3d} ; {bignum}"
        f" - {extra_cycles}"
    )


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

    printit(round(f), filter_off_value)

    for y in range(2, 2049):
        total = math.log(y) / c
        increment = round(total - rounded_total)
        rounded_total += increment
        printit(increment, filter_on_value)


if __name__ == "__main__":
    # execute only if run as a script
    main()
