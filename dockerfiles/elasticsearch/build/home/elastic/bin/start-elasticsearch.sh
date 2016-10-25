#!/bin/bash -l

args=$@

if [ -f "/home/elastic/bin/configure-elasticsearch.sh" ]
then
   /home/elastic/bin/configure-elasticsearch.sh ${args}
fi

esdir=`ls /home/elastic | grep elasticsearch`
/home/elastic/${esdir}/bin/elasticsearch
