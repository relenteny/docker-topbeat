#!/bin/bash

cwd=`pwd`

OPTS=`getopt -o wh: -l host:,wait -n $0 -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing topbeat options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

eshost="elasticsearch"
eswait="false"

while true; do
  case "$1" in
    -h | --host ) eshost=$2; shift 2 ;;
    -w | --wait ) eswait="true"; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echo "               Elasticsearch host: ${eshost}"
echo "Wait for Elasticsearch connection: ${eswait}"

topbeat_dir=`ls /opt/docker-utils | grep topbeat`
sed -i "s/##eshost##/${eshost}/" /opt/docker-utils/${topbeat_dir}/topbeat.yml

if [ "${eswait}" == "true" ]
then
   while ! echo exit | nc ${eshost} 9200; do echo "Waiting for Elasticsearch..."; sleep 5; done
fi

cd /opt/docker-utils/${topbeat_dir}
nohup ./topbeat -e -c ./topbeat.yml >topbeat.out 2>&1 &

cd $cwd
