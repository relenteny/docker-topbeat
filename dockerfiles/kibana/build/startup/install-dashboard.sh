#!/bin/bash

while ! echo exit | nc docker.elasticsearch.esmeetup.com 9200; do echo "Waiting for Elasticsearch..."; sleep 5; done

cd /home/kibana/bin

echo "Loading topbeat index mapping"
tar zxvf topbeat-1.2.3-x86_64.tar.gz
cd topbeat-1.2.3-x86_64
curl -XPUT 'http://docker.elasticsearch.esmeetup.com:9200/_template/topbeat' -d@topbeat.template.json

cd /home/kibana/bin

unzip beats-dashboards-1.2.3.zip
cd beats-dashboards-1.2.3/
./load.sh -url http://docker.elasticsearch.esmeetup.com:9200

cd /home/kibana/bin
rm -rf beats-dashboards-1.2.3*
rm -rf topbeat-1.2.3-x86_64*
