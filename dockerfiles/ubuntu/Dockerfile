###################################################################
# Dockerfile to build instance of Ubuntu with additional predefined
# configuration items
###################################################################

FROM ubuntu:16.04

MAINTAINER Ray Elenteny - Docker Meetup 10/19/2016

COPY build /opt/build

RUN apt-get update && \
    apt-get -y install zip netcat dnsutils && \

    mv /opt/build/opt/docker-utils /opt && \

    cd /opt/docker-utils && \
    tar zxvf /opt/build/distribution/topbeat-1.3.1-x86_64.tar.gz && \
    mv topbeat-1.3.1-x86_64 topbeat-1.3.1 && \
    mv /opt/build/topbeat/topbeat.yml /opt/docker-utils/topbeat-1.3.1 && \
    
    chmod +x /opt/docker-utils/bin/*.sh && \

    rm -rf /opt/build

