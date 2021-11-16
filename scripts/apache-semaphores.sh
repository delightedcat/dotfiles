#!/bin/bash

MAX_SEMAPHORES=15

IPCS=/usr/bin/ipcs
IPCRM=/usr/bin/ipcrm
MAIL=/bin/mail

COUNT=`${IPCS} | grep apache | wc -l`

if [ "$COUNT" -le $MAX_SEMAPHORES ]; then
       #all is well, there are no semaphore build-ups.
       exit 0;
fi

# We have more than MAX_SEMAPHORES, so clear them out and restart Apache.

LIST=/root/sem.txt

${IPCS} | grep apache | awk '{print $2}' > ${LIST}
for i in `cat ${LIST}`; do
{
       ${IPCRM} -s $i;
};
done;

/etc/init.d/httpd restart

TXT="${COUNT} semaphores cleared for apache for `hostname`"
exit 1
