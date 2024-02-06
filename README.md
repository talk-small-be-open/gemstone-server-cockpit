# GemStone Server Cockpit (GSC)

(Considered as alpha version at the moment)

GSC is a web based helper application to manage applications based on GsDevKit in GemStone on a Linux server.

My motivation was: I needed a tool for provisioning. I used Ansible a lot, but never got to like it. I also want to be able to manage the server semi-automatically, so that its OK if I do some stuff by hand.

GSC needs to be installed only once, for multiple GemStone projects on one server. It can do this for you:

* Install GsDevKit
* Create GemStone stones
* Manages everything on the server. Limited only by the "tools" your project scheme instantiates.
* Check the status of system services
* Give templates for config files

Prerequisites so far:

* Ubuntu server

Builtin default application scheme operates with this scenario:

* nginx as the frontend web server
* HAproxy as the reverse proxy load balancer to the multiple gems
* monit as a local monitoring service (starts and stops the stone and gems)


How it works:

* Seaside application for the UI
* It does the jobs on the server only with ssh to localhost from Pharo (So it would be prepared to control the server also remotely, in a future version)
* Your configuration of the server parameters is stored in files. So you have an easy storage and backup solution. No relevant data is stored in the pharo image. Your serverwide config file is in /etc/gsc/gsc.conf and your application specifics in /etc/gsc/applications/*.conf
* GSC is organized like a system browser in Smalltalk. You have a tree structure, displayed as columns in the UI. For example, for all your configuration of the nginx webserver, you have 1 top level entry "NGINX webserver". Each node has a view, commands and sub nodes.
* You have 1 server with many GemStone applications. Several core elements are used once for all applications.
* Install a plain Linux server, with some basic packages. Run GSC and install all additional packages and GemStone from there.
* GSC is by design not a fully automated provisioning or deploying machine. If you dont have multiple servers, it is not really a great benefit, if you have a fully automated configuration. It's better to have targeted small tools.
* GSC will observe your installation and will warn about critical observations.
* "File root" can be used to encapsulate the generated files, so your real files are not overwritten. For testing, development, or better organizing of config files.
* Structure templates, which build a whole configuration tree for some kind of application. See GSCSchemeBase and subclasses, e.g. GSCWebApplicationSchemeV1


## Installation

If you have a bare server system, with only root access, then do this first as root:

	adduser --disabled-password <username>
	adduser <username> sudo

	apt install unzip
	mkdir --mode=0775 /etc/gsc
	chgrp <username> /etc/gsc


As normal user:

Prerequisites: User must be able to 'ssh localhost' without password, so the ssh-id needs to be in the authorized keys. You need to give the local password once here, as normal user:

	ssh-keygen # Only if SSH key does not exist
	ssh-copy-id localhost

	mkdir ~/gsc
	cd ~/gsc
	curl -L https://get.pharo.org | bash
	mv Pharo.image gsc.image
	mv Pharo.changes gsc.changes

Then load the code in the Pharo image:

	./pharo gsc.image metacello install github://talk-small-be-open/gemstone-server-cockpit:master/src BaselineOfGemstoneServerCockpit

... or optional load with additional own scheme package:

	./pharo gsc.image metacello install github://xyz/mygsc:master/src BaselineOfMyGemstoneServerCockpit


This will install the code and does some after installation steps on the server. The image will be saved and closed.

## Usage

From now on, to use and run GSC, always start an SSH Tunnel e.g. on port 8888 and run the starter script, like so:

	ssh -L 8888:localhost:8650 username@hostname './gsc/start-gsc.sh'

... then go to the displayed URL http://localhost:8888/<uniqueID>


## TODO

* How to update GSC code in the pharo image? Before updating, update the git repo?

		git -C pharo-local/iceberg/talk-small-be-open/gemstone-server-cockpit/ pull
		./pharo gsc.image metacello install github://talk-small-be-open/gemstone-server-cockpit:master/src BaselineOfGemstoneServerCockpit

* How do I add a new application?
* How do I change a parameter?
* How do I add my own tool?


## Installation manually

Classical way of installing, for developers:

	Metacello new
		baseline: 'GemstoneServerCockpit';
		repository: 'github://talk-small-be-open/gemstone-server-cockpit:master/src';
		load.

	GSCCore install.
