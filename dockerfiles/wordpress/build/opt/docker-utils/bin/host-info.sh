#!/bin/bash

export MEETUP_HOSTNAME=`hostname`
export MEETUP_IPV4_ADDR=`dig +short ${MEETUP_HOSTNAME}`

# If not found via a DNS lookup, the process is not running in a Swarm.
# Lookup the IP address in /etc/hosts
if [ -z ${MEETUP_IPV4_ADDR} ]
then
   export MEETUP_IPV4_ADDR=`grep ${MEETUP_HOSTNAME} /etc/hosts | cut -d$'\t' -f1`
fi

echo "Host name:    " ${MEETUP_HOSTNAME}
echo "IPv4 address: " ${MEETUP_IPV4_ADDR}
