#!/usr/bin/env python3
import sys

def sarcasm(str):
    count = 0
    for c in str:
        print(c.upper() if count % 2 == 0 else c.lower(), end='')
        if c != ' ': count = count + 1

def main():
    if (len(sys.argv) <= 1):
        print("Usage: python3 sarcasm.py <text>")
        sys.exit(1);

    sarcasm(sys.argv[1])
    print('\n', end='')

if __name__ == "__main__":
    main()
