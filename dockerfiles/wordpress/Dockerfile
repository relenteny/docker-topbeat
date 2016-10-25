###################################################################
# Customized Wordpress to include Topbeat similar to others images
# produced in this example set.
###################################################################

FROM wordpress:php5.6

MAINTAINER Ray Elenteny - Docker Meetup 10/19/2016

COPY build /opt/build

RUN apt-get update && \
    apt-get -y install netcat dnsutils && \

    mv /opt/build/opt/docker-utils /opt && \

    cd /opt/docker-utils && \
    tar zxvf /opt/build/distribution/topbeat-1.3.1-x86_64.tar.gz && \
    mv topbeat-1.3.1-x86_64 topbeat-1.3.1 && \
    mv /opt/build/topbeat/topbeat.yml /opt/docker-utils/topbeat-1.3.1 && \
    
    chmod +x /opt/docker-utils/bin/*.sh && \

    mv /opt/build/usr/local/bin/docker-entrypoint.sh /usr/local/bin/ && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \

    rm -rf /opt/build

