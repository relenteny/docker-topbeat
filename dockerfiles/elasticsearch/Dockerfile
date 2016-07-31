######################################################################
# Dockerfile to build instance of Elasticsearch configured with Marvel
# and the mapper attachments plug-ins
######################################################################

FROM esmeetup/centos:7.07262016

MAINTAINER Ray Elenteny - Elasticsearch Meetup 07/26/2016

COPY build /opt/build

RUN adduser elastic && echo "elastic:elastic171" | chpasswd && \
    echo "elastic    ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers.d/elastic && \

    cd /opt && \
    tar zxvf /opt/build/distribution/jdk-8u91-linux-x64.tar.gz && \
    chown -R root.root /opt/jdk1.8.0_91 && \

    cd /home/elastic && \
    tar zxvf /opt/build/distribution/elasticsearch-1.7.1.tar.gz && \

    cd /home/elastic/elasticsearch-1.7.1 && \
    mkdir plugins && \
    mkdir plugins/mapper-attachments && \
    cd plugins/mapper-attachments && \
    unzip /opt/build/distribution/elasticsearch-mapper-attachments-2.7.0.zip && \

    cd /home/elastic/elasticsearch-1.7.1 && \
    mkdir plugins/marvel && \
    cd plugins/marvel && \
    unzip /opt/build/distribution/marvel-1.3.1.zip && \

    echo "export JAVA_HOME=/opt/jdk1.8.0_91" >> /home/elastic/.bashrc && \
    echo "export PATH=\$JAVA_HOME/jre/bin:\$PATH" >> .bashrc && \

    mkdir /home/elastic/bin && \
    cp /opt/build/startup/* /home/elastic/bin && \
    rm -rf /opt/build && \
    chmod +x /home/elastic/bin/*.sh && \
    chown -R elastic.elastic /home/elastic

WORKDIR /home/elastic

USER elastic
ENTRYPOINT /home/elastic/bin/start-elasticsearch.sh
