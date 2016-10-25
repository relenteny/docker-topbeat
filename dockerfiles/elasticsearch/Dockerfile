######################################################################
# Dockerfile to build instance of Elasticsearch configured with Marvel
######################################################################

FROM meetup/jre:8

MAINTAINER Ray Elenteny - Docker Meetup 10/19/2016

COPY build /opt/build

RUN adduser --disabled-password --gecos "" elastic && \

    cd /home/elastic && \
    tar zxvf /opt/build/distribution/elasticsearch-2.4.1.tar.gz && \

    java_home=`ls /opt | grep jdk` && \
    echo "export JAVA_HOME=/opt/${java_home}" >> /home/elastic/.profile && \
    echo "export PATH=\$JAVA_HOME/jre/bin:\$PATH" >> .profile && \

    echo "export ES_USE_IPV4=true" >> .profile && \

    export JAVA_HOME=/opt/${java_home} && \
    cd /home/elastic/elasticsearch-2.4.1 && \
    bin/plugin install file:///opt/build/distribution/license-2.4.1.zip && \
    bin/plugin install --batch file:///opt/build/distribution/marvel-agent-2.4.1.zip && \

    cp -r /opt/build/home/elastic/. /home/elastic && \
    chmod +x /home/elastic/bin/*.sh && \
    chown -R elastic.elastic /home/elastic && \

    rm -rf /opt/build

EXPOSE 9200 9300
WORKDIR /home/elastic
USER elastic
CMD /home/elastic/bin/start-elasticsearch.sh
