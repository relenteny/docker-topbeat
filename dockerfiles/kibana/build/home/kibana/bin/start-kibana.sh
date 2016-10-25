#!/bin/bash -l

args=$@

if [ -f "/home/kibana/bin/configure-kibana.sh" ]; then
  /home/kibana/bin/configure-kibana.sh ${args}
  rm -f /home/kibana/bin/configure-kibana.sh
fi

kibanadir=`ls /home/kibana | grep kibana`
/home/kibana/${kibanadir}/bin/kibana
