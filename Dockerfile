FROM alpine:latest

MAINTAINER nimmis <kjell.havneskold@gmail.com>

COPY etc/ /etc/
COPY boot.sh /

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk add ca-certificates rsyslog logrotate runit@testing && \
    rm -rf /var/cache/apk/*

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/boot.sh"]

