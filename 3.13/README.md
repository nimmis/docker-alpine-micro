## microcontainer based on Alpine with working init process
[![](https://images.microbadger.com/badges/image/nimmis/alpine-micro.svg)](https://microbadger.com/images/nimmis/alpine-micro "Get your own image badge on microbadger.com")

This is a very small container (total 7.7 Mb) but still have a working init process, crond, syslog and logrotate. This is the base image for all my other microcontainers

### Why use this image

The unix process ID 1 is the process to receive the SIGTERM signal when you execute a 

	docker stop <container ID>

if the container has the command `CMD ["bash"]` then bash process will get the SIGTERM signal and terminate.
All other processes running on the system will just stop without the possibility to shutdown correclty

### runit init process
In this container runit is used to handle starting and shuttning down processes automatically started

#### Adding your own startscript inside a container

Add a directory under the directory /etc/service/ that matches the process that should be started. Lets add a nginx start script to the container. First create the directory

    mkdir /etc/service/nginx
    
and then create a file named `run` i that directory with the start code fpr nginx

    #!/bin/sh
    exec 2>&1
    exec /usr/sbin/nginx -c /etc/nginx/nginx.conf  -g "daemon off;"

and make the file executable

    chmod +x /etc/service/nginx/run

that command will be started automatically when the container is started. Be sure to start the command with flags that keeps it in the foreground otherwise runit will think that the process has ended and try to restart it.

#### Adding it to the Dockerfile

The above example is done in a Dockerfile by creating a file i the same directory as the Dockerfile
as nginx.sh containing the code

    #!/bin/sh
    exec 2>&1
    exec /usr/sbin/nginx -c /etc/nginx/nginx.conf  -g "daemon off;"

and make the file executable

    chmod +x nginx.sh
    
and add this lines to Dockerfile

    ADD nginx.sh /etc/service/nginx/run

#### Environment variables in start script
If you need environment variables from the docker command line (-e,--env=[]) add

    source /etc/envvars
    
before you use them in the script file

In this container i have a scipt that handles the init process an uses the [supervisor system](http://supervisord.org/index.html) to start
the daemons to run and also catch signals (SIGTERM) to shutdown all processes started by supervisord. This is a modified version of
an init script made by Phusion. I've modified it to use supervisor in stead of runit. There are also two directories to run scripts
before any daemon is started.

#### Run script once /etc/runonce

All executable in this directory is run at start, after completion the script is removed from the directory

#### Run script every start /etc/runalways

All executable in this directory is run at every start of the container, ie, at `docker run` and `docker start`

#### Permanent output to docker log when starting container

Each time the container is started the content of the file /tmp/startup.log is displayed so if your startup scripts generate 
vital information to be shown please add that information to that file. This information can be retrieved anytime by
executing `docker logs <container id>`

### cron daemon

In many cases there are som need of things happening att given intervalls, default no cron processs is started
in standard images. In this image cron is running together with logrotate to stop the logdfiles to be
to big on log running containers.

### rsyslogd

No all services works without a syslog daemon, if you don't have one running those messages is lost in space,
all messages sent via the syslog daemon is saved in /var/log/syslog

### Docker fixes 

Also there are fixed (besideds the init process) assosiated with running linux inside a docker container.

### Installation

This continer should normaly run as a daemon i.e with the `-d` flag attached

	docker run -d nimmis/alpine-micro

Accessing the container with a shell can be done with

	docker exec -ti <container ID> /bin/sh
This is the commands used inside nimmis/alpine based containers
for extra functionality

#### set_tz

In the default configuration Alpine is set to GMT time, if you need it
to use the corret time you can change to timezone for the container 
with this command, syntax is

	set_tz <timezone>

To get list of available timezones do

	set_tz list


##### set timezone on startup

Add the environment variable TIMEZONE to the desired timezone, i.e to set timezone to 
CET Stockhome

	docker run -d -e TIMEZONE=Europa/Stockholm nimmis/alpine-micro

##### set timezone in running container

Execute the command on the container as

	docker exec -ti <docker ID> set_tz Europa/Stockholm

##### get list of timezones before starting container

Execute the following command, it will list available timezones and then
remove the container

	docker run --rm nimmis/alpine-micro set_tz list

## Issues

If you have any problems with or questions about this image, please contact us by submitting a ticket through a [GitHub issue](https://github.com/nimmis/docker-alpine-micro/issues "GitHub issue")

1. Look to see if someone already filled the bug, if not add a new one.
2. Add a good title and description with the following information.
 - if possible an copy of the output from **cat /etc/BUILDS/*** from inside the container
 - any logs relevant for the problem
 - how the container was started (flags, environment variables, mounted volumes etc)
 - any other information that can be helpful

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

## TAGs

This image only contains the latest versions of Apline, the versions are
nimmis/alpine-micro:<tag> where tag is

| Tag    | Alpine version | size |
| ------ | -------------- | ---- |
| latest |  latest/3.10    | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro.svg)](https://microbadger.com/images/nimmis/alpine-micro "Get your own image badge on microbadger.com") | 
| 3.13    |  3.13           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.13.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.13 "Get your own image badge on microbadger.com") |
| 3.12    |  3.12           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.12.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.12 "Get your own image badge on microbadger.com") |
| 3.11    |  3.11           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.11.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.11 "Get your own image badge on microbadger.com") |
| 3.10    |  3.10           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.10.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.10 "Get your own image badge on microbadger.com") |
| 3.9    |  3.9           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.9.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.9 "Get your own image badge on microbadger.com") |
| 3.8    |  3.8           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.8.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.8 "Get your own image badge on microbadger.com") |
| 3.7    |  3.7           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.7.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.7 "Get your own image badge on microbadger.com") |
| 3.6    |  3.6           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.6.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.6 "Get your own image badge on microbadger.com") |
| 3.5    |  3.5           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.5.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.5 "Get your own image badge on microbadger.com") |
| 3.4    |  3.4           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.4.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.4 "Get your own image badge on microbadger.com") |
| 3.3    |  3.3           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.3.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.3 "Get your own image badge on microbadger.com") |
| 3.2    |  3.2           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.2.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.2 "Get your own image badge on microbadger.com") |
| 3.1    |  3.1           | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:3.1.svg)](https://microbadger.com/images/nimmis/alpine-micro:3.1 "Get your own image badge on microbadger.com") |
| edge   |  edge          | [![](https://images.microbadger.com/badges/image/nimmis/alpine-micro:edge.svg)](https://microbadger.com/images/nimmis/alpine-micro:edge "Get your own image badge on microbadger.com") |

## Contributors

 - Maximilien Richer

