#####################################################
# Base JRE image for general use
#####################################################

FROM meetup/ubuntu:16.04

MAINTAINER Ray Elenteny - Docker Meetup 10/19/2016

COPY build /opt/build

RUN cd /opt && \
    tar zxvf /opt/build/distribution/server-jre-8u102-linux-x64.tar.gz && \
    chown -R root.root /opt/jdk1.8.0_102 && \
    rm -rf /opt/build
