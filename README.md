## microcontainer based on Alpine with working init process
 [![Docker Hub; nimmis/alpine-micro](https://img.shields.io/badge/dockerhub-nimmis%2Falpinei-micro-green.svg)](https://registry.hub.docker.com/u/nimmis/alpine) [![Image Size](https://img.shields.io/imagelayers/image-size/nimmis/alpine/latest.svg)](https://imagelayers.io/?images=nimmis/alpine:latest) [![Image Layers](https://img.shields.io/imagelayers/layers/nimmis/alpine/latest.svg)](https://imagelayers.io/?images=nimmis/alpine:latest)

This is a very small container (11.9 Mb) but still have a working init process, crond and syslog. This is the base image for all my other microcontainers

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

### New commands autostarted by supervisord

To add other processes to run automaticly, add a file ending with .conf  in /etc/supervisor.d/ 
with a layout like this (/etc/supervisor.d/myprogram.conf) 

	[program:myprogram]
	command=/usr/bin/myprogram

`myprogram` is the name of this process when working with supervisctl.

Output logs std and error is found in /var/log/supervisor/ and the files begins with the <defined name><-stdout|-stderr>superervisor*.log

For more settings please consult the [manual FOR supervisor](http://supervisord.org/configuration.html#program-x-section-settings)

#### starting commands from /etc/init.d/ or commands that detach with my_service

The supervisor process assumes that a command that ends has stopped so if the command detach it will try to restart it. To work around this
problem I have written an extra command to be used for these commands. First you have to make a normal start/stop command and place it in
the /etc/init.d that starts the program with

	/etc/init.d/command start or
	service command start

and stops with

        /etc/init.d/command stop or
        service command stop

Configure the configure-file (/etc/supervisor.d/myprogram.conf)

	[program:myprogram]
	command=/my_service myprogram

There is an optional parameter, to run a script after a service has start, e.g to run the script /usr/local/bin/postproc.sh av myprogram is started

        [program:myprogram]
        command=/my_service myprogram /usr/local/bin/postproc.sh

### Output information to docker logs

The console output is owned by the my_init process so any output from commands woun't show in the docker log. To send a text from any command, either
at startup och during run, append the output to the file /var/log/startup.log, e.g sending specific text to log

	echo "Application is finished" >> /var/log/startup.log

or output from script

	/usr/local/bin/myscript >> /var/log/startlog.log


	> docker run -d --name alpine nimmis/alpine
	> docker logs microbase
	*** open logfile
	*** Run files in /etc/my_runonce/
	*** Run files in /etc/my_runalways/
	*** Booting supervisor daemon...
	*** Supervisor started as PID 6
	2015-08-04 11:34:06,763 CRIT Set uid to user 0
	*** Started processes via Supervisor......
	crond                            RUNNING    pid 9, uptime 0:00:04
	rsyslogd                         RUNNING    pid 10, uptime 0:00:04

	> docker exec alpine sh -c 'echo "Testmessage to log" >> /var/log/startup.log'
	> docker logs alpine
        *** open logfile
        *** Run files in /etc/my_runonce/
        *** Run files in /etc/my_runalways/
        *** Booting supervisor daemon...
        *** Supervisor started as PID 6
        2015-08-04 11:34:06,763 CRIT Set uid to user 0
        *** Started processes via Supervisor......
        crond                            RUNNING    pid 9, uptime 0:00:04
        rsyslogd                         RUNNING    pid 10, uptime 0:00:04

	*** Log: Testmessage to log
        >

### Installation

This continer should normaly run as a daemon i.e with the `-d` flag attached

	docker run -d nimmis/alpine

but if you want to check if all services has been started correctly you can start with the following command

	docker run -ti nimmis/alpine

the output, if working correctly should be

	docker run -ti nimmis/alpine
	*** open logfile
	*** Run files in /etc/my_runonce/
	*** Run files in /etc/my_runalways/
	*** Booting supervisor daemon...
	*** Supervisor started as PID 7
	2015-01-02 10:45:43,750 CRIT Set uid to user 0
	crond[10]: crond (busybox 1.24.1) started, log level 8
	*** Started processes via Supervisor......
	crond                            RUNNING    pid 10, uptime 0:00:04
	rsyslogd                         RUNNING    pid 11, uptime 0:00:04

pressing a CTRL-C in that window  or running `docker stop <container ID>` will generate the following output

	*** Shutting down supervisor daemon (PID 7)...
	*** Killing all processes...

you can the restart that container with 

	docker start <container ID>

Accessing the container with a shell can be done with

	docker exec -ti <container ID> /bin/sh

### TAGs

This image only contains the latest versions of Apline, the versions are
nimmis/microbase:<tag> where tag is

- latest -  this gives the latest version (atm 3.3)
- 3.3    -  this gives version 3.3
- 3.2    -  this gives version 3.2
- 3.1    -  this gives version 3.1
- 2.7    -  this gives version 2.7
- 2.6    -  this gives version 2.6
- edge   -  this gives the edge version(atm 1.4.2)
- 1.4    -  this gives the latest 1.4 version (atm 1.4.2)
- 1.4.1  -  this gives the 1.4.1 version
- 1.4.2  -  this giver the 1.4.2 version
- 1.3    -  thins gives then lastest 1.3 version (1.3.3)
- 1.2    -  this gives the latest 1.2 versio (1.2.2)





Dillinger uses a number of open source projects to work properly:

* [AngularJS] - HTML enhanced for web apps!
* [Ace Editor] - awesome web-based text editor
* [Marked] - a super fast port of Markdown to JavaScript
* [Twitter Bootstrap] - great UI boilerplate for modern web apps
* [node.js] - evented I/O for the backend
* [Express] - fast node.js network app framework [@tjholowaychuk]
* [Gulp] - the streaming build system
* [keymaster.js] - awesome keyboard handler lib by [@thomasfuchs]
* [jQuery] - duh

And of course Dillinger itself is open source with a [public repository](https://github.com/joemccann/dillinger) on GitHub.

### Installation

You need Gulp installed globally:

```sh
$ npm i -g gulp
```

```sh
$ git clone [git-repo-url] dillinger
$ cd dillinger
$ npm i -d
$ mkdir -p public/files/{md,html,pdf}
$ gulp build --prod
$ NODE_ENV=production node app
```

### Plugins

Dillinger is currently extended with the following plugins

* Dropbox
* Github
* Google Drive
* OneDrive

Readmes, how to use them in your own application can be found here:

* [plugins/dropbox/README.md](https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md)
* [plugins/github/README.md](https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md)
* [plugins/googledrive/README.md](https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md)
* [plugins/onedrive/README.md](https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md)

### Development

Want to contribute? Great!

Dillinger uses Gulp + Webpack for fast developing.
Make a change in your file and instantanously see your updates!

Open your favorite Terminal and run these commands.

First Tab:
```sh
$ node app
```

Second Tab:
```sh
$ gulp watch
```

(optional) Third:
```sh
$ karma start
```

### Todos

 - Write Tests
 - Rethink Github Save
 - Add Code Comments
 - Add Night Mode

License
----

MIT


**Free Software, Hell Yeah!**

- [john gruber](http://daringfireball.net)
- [@thomasfuchs](http://twitter.com/thomasfuchs)
- [1](http://daringfireball.net/projects/markdown/)
- [marked](https://github.com/chjj/marked)
- [Ace Editor](http://ace.ajax.org)
- [node.js](http://nodejs.org)
- [Twitter Bootstrap](http://twitter.github.com/bootstrap/)
- [keymaster.js](https://github.com/madrobby/keymaster)
- [jQuery](http://jquery.com)
- [@tjholowaychuk](http://twitter.com/tjholowaychuk)
- [express](http://expressjs.com)
- [AngularJS](http://angularjs.org)
- [Gulp](http://gulpjs.com)
