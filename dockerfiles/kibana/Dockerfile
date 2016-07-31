######################################################################
# Dockerfile to build instance of Kibana configured with Beats
# dashboards
######################################################################

FROM esmeetup/centos:7.07262016

MAINTAINER Ray Elenteny - Elasticsearch Meetup 07/26/2016

COPY build /opt/build/

USER root
RUN adduser kibana && echo "kibana:kibana416" | chpasswd && \
    echo "kibana    ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers.d/kibana && \

    cd /home/kibana && \
    tar zxvf /opt/build/distribution/kibana-4.1.6-linux-x64.tar.gz && \
    mv kibana-4.1.6-linux-x64 kibana-4.1.6 && \

    cd kibana-4.1.6/config && \
    sed -i 's/localhost/docker.elasticsearch.esmeetup.com/' kibana.yml && \
    sed -i '/# startup_timeout:/a startup_timeout: 120000' kibana.yml && \

    mkdir /home/kibana/bin && \
    cd /home/kibana/bin && \

    cp /opt/build/distribution/beats-dashboards-1.2.3.zip . && \
    cp /opt/build/distribution/topbeat-1.2.3-x86_64.tar.gz . && \
    cp /opt/build/startup/* /home/kibana/bin && \

    rm -rf /opt/build && \
    chmod +x /home/kibana/bin/*.sh && \
    chown -R kibana.kibana /home/kibana

WORKDIR /home/kibana

USER kibana
ENTRYPOINT /home/kibana/bin/start-kibana.sh
