Class {
	#name : #GSCNginx,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCNginx >> build [

	self add: GSCAptPackage then: [ :apt |
		apt packageName: 'nginx' ].

	self add: GSCTextFile then: [ :file |
		file
			filePath: ('/etc/nginx/nginx.conf');
			contentTemplate: self nginxConfigTemplate
	].

	self add: GSCSystemService then: [ :service |
		service
			name: 'nginx'
	].

	self add: GSCTextFile then: [ :file |
		file
			title: 'default vhost';
			filePath: ('/etc/nginx/sites-available/default');
			contentTemplate: self defaultVhostConfigTemplate
	].
	
"TODO
  - name: User {{remoteUser}} is in group www-data (uploaded files permission)
"
]

{ #category : #'as yet unclassified' }
GSCNginx >> defaultVhostConfigTemplate [
	^ GSCSimpleTemplate source: '
# Reject access with just the IP. We do not want bots or other dark forces to annoy us
server {
		listen 80 default_server;
		listen [::]:80 default_server;

		#{% if resres.useSsl %}
		#		
		#listen 443 ssl http2 default_server;
		#listen [::]:443 ssl http2 default_server;

		#ssl_certificate /etc/letsencrypt/live/resres/fullchain.pem;
		#ssl_certificate_key /etc/letsencrypt/live/resres/privkey.pem;
		#include /etc/letsencrypt/options-ssl-nginx.conf;
		#ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

		#{% endif %}

		server_name _;

		return 444; # Special code from nginx, just fails and does not return anything to caller
}
'
]

{ #category : #'as yet unclassified' }
GSCNginx >> doCheckSyntax [
	self runSudoShellCommand: 'nginx -t'
]

{ #category : #'as yet unclassified' }
GSCNginx >> nginxConfigTemplate [
^ GSCSimpleTemplate source: '
user	www-data;
worker_processes auto;
pid /var/run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
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
		# Logging Settings
		##

		access_log /var/log/nginx/access.log;
		error_log /var/log/nginx/error.log;

		##
		# Gzip Settings
		##

		gzip on; # TBD: Needed?
		
		client_max_body_size 0; # disable limit

		# We use HAProxy as an intermediate load balancer, because its far better than nginx.
		# And, important: It queues the request per backend server instance, since we allow only
		# one single request per GemStone gem.
		#upstream haproxy_upstream { 
		#	server 127.0.0.1:9000; 
		#	keepalive 64; 
		#}

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

{ #category : #rendering }
GSCNginx >> renderBodyOn: html [
"	html iframe
		contents: [ :h | h paragraph: 'HIIII' ]"
]

{ #category : #accessing }
GSCNginx >> title [
	^ 'NGINX web server'
]
