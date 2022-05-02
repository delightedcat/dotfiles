#!/bin/bash
#
# A script that processes the entire /etc/vitual/domainowners file
# on DirectAdmin and performs the dig command on them to check on
# which server they are currently hosted.
#
# It fetches the local IP and compares it aainst each entry's
# short DIG output. It additionally fetches the nameserver
# to determine where the DNS of the specific domain is located.
#
# The output is written in such a way that it should be easy
# to grep the command's output.

# Fetch the local IP address of this machine
LOCAL_IP=$(hostname -I | awk '{split($0,a," "); print a[1]}')

cat /etc/virtual/domainowners | while read -r LINE ; do
        # Extract the domain name from the current output line.
        DOMAIN_NAME=$(echo $LINE | awk '{split($0,a,":"); print a[1]}')

        # Fetch the domain information using the DIG command.
        # An empty DOMAIN_IP means that there's no NS response.
        DOMAIN_IP=$(dig +short $DOMAIN_NAME A | tail -n 1)
        DOMAIN_NS=$(dig +short $DOMAIN_NAME NS | tail -n 1)

        if [[ $DOMAIN_IP == "" ]]; then
                echo "$DOMAIN_NAME does not return a host"
        else
                echo -n "$DOMAIN_NAME is hosted on A $DOMAIN_IP"
                # Display whether the domain is hosted on the current machine.
                if [[ $DOMAIN_IP == $LOCAL_IP ]] ; then echo -n " (local)" ; fi
                # Display the nameserver of the domain.
                echo "; NS $DOMAIN_NS"
        fi
done
