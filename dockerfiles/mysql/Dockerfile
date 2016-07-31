###################################################################
# Dockerfile to build instance of MySQL with Topbeat
# configured to report process statistics
###################################################################

FROM mariadb:latest

MAINTAINER Ray Elenteny - Elasticsearch Meetup 07/26/2016

COPY build /opt/build/

RUN cd / && \
    cp /opt/build/distribution/topbeat-1.2.3-x86_64.tar.gz . && \
    tar zxvf topbeat-1.2.3-x86_64.tar.gz && \
    rm topbeat-1.2.3-x86_64.tar.gz && \
    cd /topbeat-1.2.3-x86_64 && \
    sed -i 's/system: true/system: false/' topbeat.yml && \
    sed -i 's/localhost:9200/docker.elasticsearch.esmeetup.com:9200/' topbeat.yml && \

    cp /opt/build/startup/docker-entrypoint.sh /usr/local/bin && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \

    cd / && \
    rm -rf /opt/build
