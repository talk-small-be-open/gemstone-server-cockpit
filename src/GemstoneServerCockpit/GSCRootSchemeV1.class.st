Class {
	#name : #GSCRootSchemeV1,
	#superclass : #GSCRootScheme,
	#category : #'GemstoneServerCockpit-Scheme'
}

{ #category : #'as yet unclassified' }
GSCRootSchemeV1 >> buildRootTool [
	| root |

	root := super buildRootTool.

	root add: GSCFolder then: [ :folder |
		folder name: 'Server software'.

		"hardcoded apt packages for the server setup"
		"'mailutils' ""for ngxblocker to send emails"""
		{'logrotate'. 'ufw'. 'git'. 'htop'. 'unzip'. 'zip'. 'pigz'. 'aptitude'. 'mosh'.
		'cronic'. 'goaccess'. 'lnav'. 'ansible'. } do: [ :each |
			folder add: GSCAptPackage then: [ :apt |
				apt packageName: each ] ].
		
		"additional apt packages from the config"
		(config at: 'server:aptPackages') do: [ :each |
			folder add: GSCAptPackage then: [ :apt |
				apt packageName: each ] ].

		(config at: 'server:snapPackages') do: [ :each |
			folder add: GSCSnapPackage then: [ :apt |
				apt packageName: each ] ].

"		folder add: GSCSnapPackage then: [ :apt |
			apt packageName: 'certbot' ]."
	].
	
	root add: GSCNginx.
	
	root add: GSCHaproxy.
	
	root add: GSCMonit.
	
	root add: GSCGsDevKit.

	root add: GSCAnsibleTasks then: [ :ansible |
		ansible addTasksJson: '
[
    {
        "name": "Set timezone to Switzerland",
        "timezone": {
            "name": "Europe/Zurich"
        }
    }
]
'
	].

	root add: GSCFolder then: [ :folder |
		folder name: 'Utilities'.

		folder add: GSCShellConsole.
		folder add: GSCGeneralTool then: [ :tool |
			tool actionBlock: [ GSCCore instance clearSudoPassword ].
			tool title: 'reset sudo'
	].	].

	^ root
]

{ #category : #'as yet unclassified' }
GSCRootSchemeV1 >> templateHaproxyConfig [
	^ GSCSttTemplate sttString:
'global
	log /dev/log	 local0
	log /dev/log	 local1 notice
	chroot /var/lib/haproxy
	user haproxy
	group haproxy
	daemon
	unix-bind user root group www-data mode 660

defaults
	log global
	mode http
	option httplog
	option dontlognull
	retries 3
	timeout connect 5000
	timeout client	50000
	timeout server	50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

frontend stats
	bind 127.0.0.1:8404
	stats enable
	stats uri /stats
	stats refresh 10s
	#log false
	option dontlog-normal
	# stats admin if LOCALHOST

<?stt me haproxySiteConfigs do: [ :each | ?>
<?stt= each contentString ?><?stt ] ?>'
]

{ #category : #'as yet unclassified' }
GSCRootSchemeV1 >> templateMonitConfig [
	^ GSCSttTemplate sttString:
'set daemon 60
	with start delay 30
	
set logfile /var/log/monit.log

set idfile /var/lib/monit/id
set statefile /var/lib/monit/state

set mailserver localhost

set eventqueue
	basedir /var/lib/monit/events
	slots 100

set httpd port 2812 and
	use address localhost
	allow localhost
	
set alert <?stt= me serverAdminEmail ?> not on { instance, action }
	 
include /etc/monit/conf.d/*
'
]

{ #category : #'as yet unclassified' }
GSCRootSchemeV1 >> templateNginxConfig [
	^ GSCSttTemplate sttString:
'user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;

	# also in ngxblocker: server_names_hash_bucket_size 64;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on; # TBD: Needed?
	
	client_max_body_size 0; # disable limit

	#
	# Limits
	#
	# Consider: Seaside uses 2 requests per hit (1 for redirect message)
	
	# Define request limit, used for demo and app.
	
	limit_req_zone $binary_remote_addr zone=demo:5m rate=2r/s;

	# Consider: Users are often coming from the same class room, therefore same IP! Dont limit to hard!
	# What we want is to ban idiots
	limit_req_zone $binary_remote_addr zone=app:10m rate=20r/s;

	# We need to manually re-add this. ngxblocker out-comments this in /etc/nginx/conf.d/botblocker-nginx-settings.conf
	# because of conflict avoidance. But zone flood needs to exist.
	limit_req_zone $binary_remote_addr zone=flood:50m rate=90r/s;

	# limit_conn_zone $binary_remote_addr zone=app:10m
	limit_req_status 509; # = "Bandwidth exceeded"


	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;

}
'
]
