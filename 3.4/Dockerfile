FROM alpine:3.4

MAINTAINER nimmis <kjell.havneskold@gmail.com>


RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk add ca-certificates rsyslog logrotate runit@testing && \
    mkdir /etc/run_always && mkdir /etc/run_once && \
    apk add git && git clone https://github.com/nimmis/docker-utils.git && \
    cp -p docker-utils/alpine/bin/* /usr/local/bin && \
    cp -Rp docker-utils/alpine/runit /etc && \
    cp -Rp docker-utils/alpine/service /etc && \
    cp -Rp docker-utils/alpine/root/* / && \
    rm -Rf docker-utils && \
    apk del git && \
    sed  -i "s|\*.emerg|\#\*.emerg|" /etc/rsyslog.conf && \
    rm -rf /var/cache/apk/*

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/boot.sh"]

