Class {
	#name : #GSCNginxSite,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCNginxSite >> appUrlPaths [
	^ self configAt: 'web:appUrlPaths'
]

{ #category : #building }
GSCNginxSite >> build [

	self add: GSCTextFile then: [ :file |
		file
			filePath: ('/etc/nginx/sites-available/', self appShortCode, '.vhost');
			contentTemplate: self vhostConfigTemplate
	].
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> domains [
	^ self configAt: 'web:domains'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> nginxDomainsString [
	^ self domains joinUsing: String space
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> sttBlockIdiots [
	^ '
# Simple block some annoying idiots
# OPTIMIZE: Use something like https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
# if ($http_user_agent ~ (LieBaoFast|UCBrowser|MQQBrowser|Mb2345Browser|zh-CN|MicroMessenger|zh_CN|Kinza|Bytespider|Baiduspider|Sogou|AspiegelBot|PetalBot|adscanner|serpstatbot|spaziodat|undefined|Barkrowler|Seekport) ) {
# 	 return 403;
# }


##
# Nginx Bad Bot Blocker Includes
# REPO: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
##
include /etc/nginx/bots.d/ddos.conf;
include /etc/nginx/bots.d/blockbots.conf;
'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> sttCachedLocations [
	^ '
# Caching, see https://web.dev/http-cache/

## Aggressively cache assets
#location /assets {
#	add_header Cache-Control "public, max-age=31536000";
#	etag on;
#	access_log off;

#	# Assets streaming/download slow down after first couple megabytes
#	limit_rate 5m;
#	limit_rate_after 10m;
#}

# Moderately cache application static files CSS/JS
<?stt {''/js''. ''/css''. ''/images''. ''/site''. ''/lib''} do: [ :each | ?>
	location <?stt= each ?> {
		<?stt me application isBeta ifTrue: [ ?>
		# Cache for 5 minutes
		add_header Cache-Control "public, no-cache, max-age=300";
		<?stt ] ifFalse: [ ?>
		# Cache for 24h
		add_header Cache-Control "public, no-cache, max-age=361440";
		<?stt ] ?>

		etag on;
		access_log off;
	}
<?stt ] ?>
'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> sttListenPort [
	^ '
<?stt me useSsl ifTrue: [ ?>

listen 443 ssl http2;
listen [::]:443 ssl http2;

ssl_certificate /etc/letsencrypt/live/via/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/via/privkey.pem;
include /etc/letsencrypt/options-ssl-nginx.conf;
ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

<?stt ] ifFalse: [ ?>
listen 80;
listen [::]:80;
<?stt ] ?>
'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> sttProxyToHaproxy [
	^ '
# Never cache anything from the Seaside application
expires -1;
add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0, proxy-revalidate";

# Allow connections from Browser to websocket
add_header Content-Security-Policy "connect-src https: ''self'' wss://$host;";

proxy_pass http://haproxy_upstream;

# For upstream keepalive to work properly
proxy_http_version 1.1;
proxy_set_header Connection "";

# Forwards
#proxy_set_header X-Forwarded-For $remote_addr;
proxy_set_header        Host               $host;
proxy_set_header        X-Real-IP          $remote_addr;
proxy_set_header        X-Forwarded-For    $proxy_add_x_forwarded_for;
proxy_set_header        X-Forwarded-Host   $host:443;
proxy_set_header        X-Forwarded-Server $host;
proxy_set_header        X-Forwarded-Port   443;
proxy_set_header        X-Forwarded-Proto  https;

# nginx should handle http errors from haproxy
proxy_intercept_errors on;
'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> useSsl [
	^ self configAt: 'web:useSsl'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> vhostConfigTemplate [
	^ GSCSttTemplate tool: self sttString: '
server {

		', self sttListenPort, '

		server_name <?stt= me nginxDomainsString ?>;

		root <?stt= me webRoot ?>;

		', self sttBlockIdiots, '

		# Pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
		#
		# For uploader PlUpload
		location ~ \.php$ {
				include snippets/fastcgi-php.conf;
				fastcgi_pass unix:/run/php/php7.2-fpm.sock;
		}

		# If root is accessed, then redirect to app
		location = / {
				return 301 $scheme://$host/app;
		}

		<?stt me appUrlPaths do: [ :each | ?>
			# Speedup access to main app (Frontend and Backend)
			location /<?stt= each ?> {
					', self sttProxyToHaproxy, '
			}
		<?stt ] ?>


		#{% for path in [''/keepalive'', ''/ping''] -%}
		## Speedup access to some services (no auth, no bandwith)
		#location {{path}} {
		#		access_log off;
		#		 self sttProxyToHaproxy
		#}
		#{% endfor %}

		', self sttCachedLocations, '


		# General rule, serve static file or redirect to app
		# Serves only as a general fallback, since for most frontend pathes
		# we have a dedicated rule
		location / {
				try_files $uri @haproxy;
		}

		location @haproxy {
			', self sttProxyToHaproxy, '
		}


		# X-Sendfile for generated files (ZIP, PDF, ...) and asset file download
		#location {{via.installationPath}}/tmp {
		#	internal;
		#	root /;
		#}

		# TBD: Hide and secure
		# or just use the CLI features, see https://sleeplessbeastie.eu/2020/01/29/how-to-use-haproxy-stats-socket/
		location /ha-status {
			access_log off;
			proxy_pass http://127.0.0.1:8404/stats;
		}

		# Custom error page, if App is not running (looks nicer)
		error_page 500 /errors/500.html;
		error_page 502 /errors/502.html;
		error_page 503 /errors/503.html;
		error_page 504 /errors/503.html;

		location /errors/ {
		  internal;
		}
}


<?stt me useSsl ifTrue: [ ?>
# Redirect HTTP->HTTPS
server {
		listen	 80;
		server_name <?stt= me nginxDomainsString ?>;
		access_log off;
		return 301 https://$host$request_uri;
}
<?stt ] ?>

'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> webRoot [
	^ (self configAt: 'server:installationPath'), '/web_root'
]
