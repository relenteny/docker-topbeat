#!/bin/bash

kibanadir=`ls /home/kibana | grep kibana`
es_service="elasticsearch"

OPTS=`getopt -o s: -l elasticsearch-service: -n $0 -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing startup options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    -s | --elasticsearch-service ) es_service=$2; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echo "Elasticsearch service:  ${es_service}"

while ! echo exit | nc ${es_service} 9200; do echo "Waiting for Elasticsearch..."; sleep 5; done

echo "elasticsearch.url: \"http://${es_service}:9200\"" >> /home/kibana/${kibanadir}/config/kibana.yml

cd /home/kibana/${kibanadir}
bin/kibana plugin --install marvel --url file:///home/kibana/bin/marvel-2.4.1.tar.gz
rm /home/kibana/bin/marvel-2.4.1.tar.gz

statuscode=`curl --silent -XHEAD --write-out "%{http_code}" http://${es_service}:9200/.kibana`
if [ $statuscode -eq 200 ]
then
    echo "Kibana has been set up.  Skipping Kibana initialization."
    cd /home/kibana/bin
    rm -rf beats-dashboards-1.3.1*
    exit 0
fi

cd /home/kibana/bin

topbeatdir=`ls /opt/docker-utils | grep topbeat`
echo "Loading topbeat index mapping"
curl -XPUT "http://${es_service}:9200/_template/topbeat" -d@/opt/docker-utils/${topbeatdir}/topbeat.template.json

cd /home/kibana/bin

unzip beats-dashboards-1.3.1.zip
cd beats-dashboards-1.3.1/
./load.sh -url http://${es_service}:9200

cd /home/kibana/bin
rm -rf beats-dashboards-1.3.1*

