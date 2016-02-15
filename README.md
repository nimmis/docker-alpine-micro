## microcontainer based on Alpine with working init process
[![](https://badge.imagelayers.io/nimmis/alpine-micro:latest.svg)](https://imagelayers.io/?images=nimmis/alpine-micro:latest)

This is a very small container (11.9 Mb) but still have a working init process, crond, syslog and logrotate. This is the base image for all my other microcontainers

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

### TAGs

This image only contains the latest versions of Apline, the versions are
nimmis/alpine-micro:<tag> where tag is

| Tag    | Alpine version | size |
| ------ | -------------- | ---- |
| latest |  latest/3.3    | [![](https://badge.imagelayers.io/nimmis/alpine-micro:latest.svg)](https://imagelayers.io/?images=nimmis/alpine-micro:latest) | 
| 3.3    |  3.3           | [![](https://badge.imagelayers.io/nimmis/alpine-micro:3.3.svg)](https://imagelayers.io/?images=nimmis/alpine-micro:3.3) |
| 3.2    |  3.2           | [![](https://badge.imagelayers.io/nimmis/alpine-micro:3.2.svg)](https://imagelayers.io/?images=nimmis/alpine-micro:3.2) |
| 3.1    |  3.1           | [![](https://badge.imagelayers.io/nimmis/alpine-micro:3.1.svg)](https://imagelayers.io/?images=nimmis/alpine-micro:3.1) |
| edge   |  edge          | [![](https://badge.imagelayers.io/nimmis/alpine-micro:edge.svg)](https://imagelayers.io/?images=nimmis/alpine-micro:edge) |
