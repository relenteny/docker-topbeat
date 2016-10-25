#!/bin/bash -l

esdir=`ls /home/elastic | grep elasticsearch`

cluster_name="meetup-elastic-cluster"
node_prefix="meetup-elastic-node"
minimum_masters=1

OPTS=`getopt -o c:p:m: -l cluster-name:,node-prefix:,minimum-masters: -n $0 -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing startup options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    -c | --cluster-name ) cluster_name=$2; shift 2 ;;
    -p | --node-prefix ) node_prefix=$2; shift 2 ;;
    -m | --minimum-masters ) minimum_masters=$2; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echo "Cluster name:    ${cluster_name}"
echo "Node prefix:     ${node_prefix}"
echo "Minimum masters: ${minimum_masters}"

. /opt/docker-utils/bin/host-info.sh
eshost=${MEETUP_HOSTNAME}
ipv4_addr=${MEETUP_IPV4_ADDR}

nodename="${node_prefix}-${eshost}"
dataroot="/home/elastic/data/"
datapath="${dataroot}${nodename}"

echo "Node name:       ${nodename}"
echo "Data path:       ${dataroot}"

echo "cluster.name: ${cluster_name}" >> /home/elastic/${esdir}/config/elasticsearch.yml
echo "node.name: ${nodename}" >> /home/elastic/${esdir}/config/elasticsearch.yml
echo "network.host: 0.0.0.0" >> /home/elastic/${esdir}/config/elasticsearch.yml
echo "path.data: ${datapath}" >> /home/elastic/${esdir}/config/elasticsearch.yml

echo "transport.host: ${ipv4_addr}" >> /home/elastic/${esdir}/config/elasticsearch.yml

#  Assumes overlay network created with subnet 10.10.1.0/24
echo "discovery.zen.ping.unicast.hosts: 10.10.1.3" >> /home/elastic/${esdir}/config/elasticsearch.yml

if [ ${minimum_masters} -gt 1 ]
then
    echo "discovery.zen.minimum_master_nodes: ${minimum_masters}" >> /home/elastic/${esdir}/config/elasticsearch.yml
fi
