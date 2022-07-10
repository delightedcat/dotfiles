#!/bin/bash

LOADAVG=$(/usr/bin/uptime | awk '{print $12}' | cut -d "," -f 1)

if [[ $LOADAVG > $(nproc) ]] ; then
        echo "load average is high ($LOADAVG)"
        echo "killing all dataskq processes..."

        /usr/bin/killall -USR1 dataskq
fi
