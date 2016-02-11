FROM alpine:latest

MAINTAINER nimmis <kjell.havneskold@gmail.com>

COPY boot.sh /

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk add ca-certificates rsyslog logrotate runit@testing && \
    mkdir /etc/run_always && mkdir /etc/run_once && \
    apk add git && git clone https://github.com/nimmis/docker-alpine-bin.git && \
    cp -p docker-alpine-bin/bin/* /usr/local/bin && \
    cp -Rp docker-alpine-bin/runit /etc && \
    cp -Rp docker-alpine-bin/service /etc && \
    rm -Rf docker-alpine-bin && \
    apk del git && \
    sed  -i "s|\*.emerg|\#\*.emerg|" /etc/rsyslog.conf && \
    rm -rf /var/cache/apk/*

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/boot.sh"]

