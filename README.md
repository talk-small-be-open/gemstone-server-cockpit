# GemStone Server Cockpit (GSC)

(Considered as alpha version at the moment)

GSC is a web based provisioning helper application to manage applications based on GemStone's GsDevKit on a Linux server.

My motivation was:

* I needed a tool for provisioning. I used Ansible a lot, but it never did fit my needs.
* I also want to be able to manage the server semi-automatically, so that its OK if I do some stuff by hand.
* It should not do all the stuff alltogether, but every single piece as a single task. That gives you more insight and better understanding. But it is also more work for you.

It can do this for you:

* Install GsDevKit
* Create GemStone stones
* Manages "everything" on the server. Limited only by the "tools" your project scheme instantiates.
* Check the status of system services
* Give templates for config files and warn if they differ
* 

Prerequisites so far:

* Ubuntu server

Builtin default application scheme operates with this scenario:

* nginx as the frontend web server
* HAproxy as the reverse proxy load balancer to the multiple gems
* monit as a local monitoring service (starts and stops the stone and gems)


How it works:

* Pharo as platform
* Seaside application for the UI
* It does the jobs on the server only with "ssh to localhost" from Pharo (So it would be prepared to control the server also remotely, in a future version)
* Your configuration of the server parameters is stored solely in some text files (STON format). So you have an easy storage and backup solution. No relevant data is stored in the pharo image. Your serverwide config file is in /etc/gsc/gsc.conf and your application specifics in /etc/gsc/applications/*.conf
* GSC UI is organized like a system browser in Smalltalk. You have a tree structure, displayed as columns in the UI. For example, for all your configuration of the nginx webserver, you have 1 top level entry "NGINX webserver". Each node has a view, commands and multiple sub nodes.
* GSC is by design not a fully automated provisioning or deploying machine. If you dont have multiple servers, it is not really a great benefit, if you have a fully automated configuration. It's better to have targeted small tools.
* GSC will observe your installation and will warn about critical observations. Each node can check itself and display a warning state.
* Prefixed "File root path" can be used to sandbox the generated files, so your real files are not overwritten. For testing, development, or better organizing of config files.
* Organized as schemes, which build a whole configuration tree for some kind of application. See GSCSchemeBase and subclasses, e.g. GSCWebApplicationSchemeV1. If your application needs this or that tool, it will be built in that scheme.
* Get a plain Linux server, with some basic packages. Install and run GSC and install all additional packages and GemStone from there.

## Installation

GSC needs to be installed only once per server, for multiple GemStone projects.

(Optional) If you have a bare server system, with only root access, then ensure this first as root:

	# As root
	adduser --disabled-password <username>
	adduser <username> sudo
	apt install unzip

Create the GSC folder for config files (as root):

	# As root
	mkdir --mode=0775 /etc/gsc
	chgrp <username> /etc/gsc


As normal user:

Prerequisites: User must be able to 'ssh localhost' without password, so the ssh-id needs to be in the authorized keys. You need to give the local password once here, as normal user:

	# As <username>
	ssh-keygen # Only if SSH key does not exist
	ssh-copy-id localhost # Or alternatively cat .ssh/id_rsa.pub >> .ssh/authorized_keys

	mkdir ~/gsc
	cd ~/gsc
	curl -L https://get.pharo.org | bash
	mv Pharo.image gsc.image
	mv Pharo.changes gsc.changes

Check and make sure, that you can ssh localhost without a password and accept the verification once:

	ssh localhost

Then load the code in the Pharo image:

	./pharo gsc.image metacello install github://talk-small-be-open/gemstone-server-cockpit:master/src BaselineOfGemstoneServerCockpit

(... or optionally load with your own scheme package:)

	./pharo gsc.image metacello install github://xyz/mygsc:master/src BaselineOfMyGemstoneServerCockpit


This will install the code and does some after installation steps on the server. The image will be saved and closed.

## Usage

From now on, to use and run GSC, always start an SSH Tunnel e.g. on port 8888 and run the starter script, like so:

	ssh -t -Y -L 8888:localhost:8650 username@hostname './gsc/start-gsc.sh'

-t is used to forward also Ctrl-C to quit pharo (and not just the SSH connection)
-Y is used to optionally start tode client over X11 forwarding
If you need to debug pharo in UI, then use "start-gsc.sh ui" and connect with xpra to the remote display.

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
