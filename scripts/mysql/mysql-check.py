#!/usr/bin/env python3
import os

def main():
    f = open("/proc/loadavg", "r")

    loadavg = f.read()
    loadavg = loadavg.split()

    current = float(loadavg[0])
    previous = float(loadavg[1])

    print("loadavg: current: %s previous: %s" % (current, previous))

    if (float(loadavg[0]) > 1.0 and float(loadavg[1]) > 1.0):
        os.system("systemctl restart mariadb.service")
        print("restarting mariadb.service")

    f.close()

if __name__ == "__main__":
    main()
