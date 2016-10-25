######################################################################
# Dockerfile to build instance of Kibana configured with Beats
# dashboards and Marvel
######################################################################

FROM meetup/ubuntu:16.04

MAINTAINER Ray Elenteny - Docker Meetup 10/19/2016

COPY build /opt/build

RUN apt-get update && \
    apt-get install -y curl && \

    adduser --disabled-password --gecos "" kibana && \

    cd /home/kibana && \
    tar zxvf /opt/build/distribution/kibana-4.6.1-linux-x86_64.tar.gz && \
    mv kibana-4.6.1-linux-x86_64 kibana-4.6.1 && \

    cp -r /opt/build/home/kibana/. /home/kibana && \
    chmod +x /home/kibana/bin/*.sh && \
    cp /opt/build/distribution/beats-dashboards-1.3.1.zip /home/kibana/bin && \
    cp /opt/build/distribution/marvel-2.4.1.tar.gz /home/kibana/bin && \
    chown -R kibana.kibana /home/kibana && \

    rm -rf /opt/build

EXPOSE 5601
WORKDIR /home/kibana
USER kibana
CMD /home/kibana/bin/start-kibana.sh
