Class {
	#name : #GSCWebApplicationSchemeV1,
	#superclass : #GSCApplicationScheme,
	#category : #'GemstoneServerCockpit-Scheme'
}

{ #category : #building }
GSCWebApplicationSchemeV1 >> buildApplicationToolInto: aRootTool [
	| app |

"	app := GSCApplication new.
	app config: config.
	aRootTool addTool: app."
	
"	appConfig := aRootTool config copyWith: config."

	app := aRootTool add: GSCApplication then: [ :a |
		a scheme: self
	].
	
	app add: GSCNginxSite. "then: [ :site |
		site web
	]."

	app add: GSCHaproxySite.
	
	app add: GSCGemstoneStone then: [ :stone |
"		stone add: GSCDummy."
"		stone add: GSCShellCommand then: [ :shell |
			shell cmd: 'ping -t 5 google.com'
		]"
	].
	
	app add: GSCGemstoneGems.
	
	
	app add: GSCAnsibleTasks then: [ :ansible |
		ansible addTasksJson: (config at: 'ansibleTasksJson')
	].

	"additional apt packages from the config"
	(config at: 'aptPackages') do: [ :each |
		app add: GSCAptPackage then: [ :apt |
			apt packageName: each ] ].

	"additional apt packages from the config"
	(config at: 'snapPackages') do: [ :each |
		app add: GSCSnapPackage then: [ :apt |
			apt packageName: each ] ].
	
	^ app
]

{ #category : #building }
GSCWebApplicationSchemeV1 >> defaultConfigurationBuilder [
	
	| builder |
	
	builder := super defaultConfigurationBuilder.
	
	"Meta - about the project"
	builder project
		shortCode: 'MyWebApp';
		name: 'My web application';
		email: 'andreas.brodbeck@mindclue.ch'.

	"Source code repository"
	builder sourceCode __example
		gitUrl: 'ssh://git@yourhost/repo.git';
		metacelloName: 'WebApp';
		gitBranch: 'master'.

	"Files in repositories"
	(builder gitRepositories __example)
		path: '/opt/webapp/main';
		url: 'ssh://git@yourhost/repo.git';
		branch: 'master'.

"	(conf project gitRepositories school)
		path: '/opt/albus/school';
		url: 'ssh://gitolite@mindclue.dyndns.org:3690/kshp/albus_school_kshp.git';
		branch: 'master'."

	builder gemstone
		version: '3.6.5';
		keyfile: nil.

	builder web
		webRoot: '/opt/webapp/main/web_root';
		useSsl: false;
		appUrlPaths: {'app'. 'admin'};
		domains: {'www.example.com'. };
		workersCount: 3;
		nginxIncludeFile: ''.

	builder ansibleTasksJson: '[ { } ]'.

	builder aptPackages: #().
	builder snapPackages: #().

	builder tmpDir: '/tmp'.
	
	builder isBeta: true.

	^ builder
]

{ #category : #'as yet unclassified' }
GSCWebApplicationSchemeV1 >> templateGemMonitConfig [
	^ GSCSttTemplate sttString:
'# GEM ON PORT <?stt= me portNumber ?>
check process <?stt= me monitCheckName ?> with pidfile <?stt= me pidFilePath pathString ?>
	DEPENDS ON <?stt= me stoneTool netldiMonitCheckName ?>
	ONREBOOT START
	GROUP <?stt= me monitGroupName ?>
	GROUP <?stt= me appShortCode ?>
	GROUP gemstone_gems
	MODE ACTIVE
	start program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> <?stt= me gsHome ?>/bin/todeIt <?stt= me stoneName ?> /home/seaside/gemServer --restart=seaside<?stt= me gemIndex ?>'' " as uid "<?stt= me serverUsername ?>" gid "<?stt= me serverUsername ?>"
	stop program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> <?stt= me gsHome ?>/bin/todeIt <?stt= me stoneName ?> /home/seaside/gemServer --stop=seaside<?stt= me gemIndex ?>'' " as uid "<?stt= me serverUsername ?>" gid "<?stt= me serverUsername ?>" with timeout 90 seconds
	if 7 restarts within 10 cycles then stop
#	if failed url http://127.0.0.1:<?stt= me portNumber ?>/ping and content == "OK" for 2 cycles then alert
#	if totalmem > 700 Mb then alert
	if cpu > 60% for 4 cycles then alert
'
]

{ #category : #'as yet unclassified' }
GSCWebApplicationSchemeV1 >> templateHaproxySite [
	^ GSCSttTemplate sttString:
'frontend <?stt= me appShortCode ?>_nginx
	bind unix@/tmp/haproxy_<?stt= me appShortCode ?>.socket
	default_backend <?stt= me appShortCode ?>_gems

	# # TODO: Rate limiting, sliding window, see https://www.haproxy.com/blog/four-examples-of-haproxy-rate-limiting/
	# stick-table  type ip  size 100k  expire 30s  store http_req_rate(10s)
	# http-request track-sc0 src
	# http-request deny deny_status 429 if { sc_http_req_rate(0) gt 20 }

	# # or this?
	# rate-limit sessions 10

	# # or this?
	# # https://medium.com/faun/understanding-rate-limiting-on-haproxy-b0cf500310b1
	# # ACL function declarations
	# acl is_abuse src_http_req_rate(Abuse) ge 10  
	# acl inc_abuse_cnt src_inc_gpc0(Abuse) gt 0   
	# acl abuse_cnt src_get_gpc0(Abuse) gt 0
	# # Rules
	# tcp-request connection track-sc0 src table Abuse
	# tcp-request connection reject if abuse_cnt
	# http-request deny if abuse_cnt
	# http-request deny if is_abuse inc_abuse_cnt

	# see also
	# https://gist.github.com/procrastinatio/6b6579230d99be5bfa26d04acd788e7a


backend <?stt= me appShortCode ?>_gems
	balance roundrobin

	# maxconnrate 5 # per second
	default-server check inter 30s maxconn 1 maxqueue 10 non-stick

	# # Save real ip in the table
	# stick store-request req.fhdr(X-Forwarded-For) table Abuse

	# option httpclose
	# Because of Seaside server, which cant handle keepalive?
	option http-server-close
		
	# DONT, X-Forwarded-For is already added by nginx		option forwardfor

	option httpchk GET /ping
	# http-check send

	<?stt me gemPorts do: [ :each | ?>
	server gem<?stt= each asString ?> 127.0.0.1:<?stt= each asString ?><?stt ] ?>
'
]

{ #category : #'as yet unclassified' }
GSCWebApplicationSchemeV1 >> templateNetldiMonitConfig [

	^ GSCSttTemplate sttString:
'# NETLDI
check process <?stt= me netldiMonitCheckName ?> matching "^/opt/.*/sys/netldid <?stt= me stoneName ?>_ldi .*$"
	ONREBOOT START
	DEPENDS ON <?stt= me monitCheckName ?>
	MODE ACTIVE
	GROUP <?stt= me appShortCode ?>
	GROUP gemstone_netldis
	start program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> USER=<?stt= me serverUsername ?> <?stt= me gsHome ?>/bin/startNetldi <?stt= me stoneName ?>''" as uid "<?stt= me serverUsername ?>" gid "<?stt= me serverUsername ?>"
	stop program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> USER=<?stt= me serverUsername ?> <?stt= me gsHome ?>/bin/stopNetldi <?stt= me stoneName ?>''" as uid "<?stt= me serverUsername ?>" gid "<?stt= me serverUsername ?>" with timeout 90 seconds
	if 7 restarts within 10 cycles then stop
	# if totalmem > 700 Mb then alert
	if cpu > 60% for 4 cycles then alert
'
]

{ #category : #'as yet unclassified' }
GSCWebApplicationSchemeV1 >> templateNginxSiteVhost [
	| sttListenPort sttBlockIdiots sttProxyToHaproxy sttCachedLocations |
	
	sttListenPort := '<?stt me useSsl ifTrue: [ ?>
	listen 443 ssl http2;
	listen [::]:443 ssl http2;

	ssl_certificate <?stt= me sslCertificate fullchainFilePath ?>;
	ssl_certificate_key <?stt= me sslCertificate keyFilePath ?>;
	#include /etc/letsencrypt/options-ssl-nginx.conf;
	#ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
<?stt ] ifFalse: [ ?>
	listen 80;
	listen [::]:80;
<?stt ] ?>'.

sttBlockIdiots := '
	##
	# Nginx Bad Bot Blocker Includes
	# REPO: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
	##
	include /etc/nginx/bots.d/ddos.conf;
	include /etc/nginx/bots.d/blockbots.conf;
'.

sttProxyToHaproxy := '
	# Never cache anything from the Seaside application
	expires -1;
	add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0, proxy-revalidate";

	# Speed limits. Requests to the actual app behind HAProxy should be restricted.
	limit_req zone=app burst=30;

	# Allow connections from Browser to websocket
	# add_header Content-Security-Policy "connect-src https: ''self'' wss://$host;";

	# proxy_pass http://127.0.0.1:<?stt= me haproxyPortNumber ?>;
	proxy_pass http://unix:/tmp/haproxy_<?stt= me appShortCode ?>.socket:;
	proxy_socket_keepalive on;

	# For upstream keepalive to work properly
	proxy_http_version 1.1;
	proxy_set_header Connection "";

	# Forwards
	proxy_set_header        Host               $host;
	proxy_set_header        X-Real-IP          $remote_addr;
	proxy_set_header        X-Forwarded-For    $proxy_add_x_forwarded_for;
	proxy_set_header        X-Forwarded-Host   $host:443;
	proxy_set_header        X-Forwarded-Server $host;
	proxy_set_header        X-Forwarded-Port   443;
	proxy_set_header        X-Forwarded-Proto  https;

	# nginx should handle http errors from haproxy
	proxy_intercept_errors on;
'.


sttCachedLocations := '
	# Caching, see https://web.dev/http-cache/
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
'.

	^ GSCSttTemplate sttString:
'server {
', sttListenPort, '

	server_name <?stt= me nginxDomainsString ?>;

	root <?stt= me webRoot pathString ?>;

	', sttBlockIdiots, '

	# Pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	# For uploader PlUpload
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/run/php/php7.2-fpm.sock;
	}

	# If root is accessed, then redirect to main app
	location = / {
		return 302 $scheme://$host/<?stt= me appUrlPathMain ?>;
	}

	<?stt me appUrlPaths do: [ :each | ?>
	# Speedup access to main app (Frontend and Backend)
	location /<?stt= each ?> {
		', sttProxyToHaproxy, '
	}
	<?stt ] ?>


	<?stt {''/keepalive''. ''/ping''} do: [ :each | ?>
	# Speedup access to some services (no auth, no bandwith)
	location <?stt= each ?> {
		access_log off;
		', sttProxyToHaproxy, '
	}
	<?stt ] ?>

	', sttCachedLocations, '


	# General rule, serve static file or redirect to app
	# Serves only as a general fallback, since for most frontend pathes
	# we have a dedicated rule
	location / {
		try_files $uri @haproxy;
	}

	location @haproxy {
		', sttProxyToHaproxy, '
	}

<?stt me tmpDir ifNotBlank: [ :tmpDir | ?>
	# X-Sendfile for generated files (ZIP, PDF, ...) and asset file download
	location <?stt= tmpDir pathString ?> {
		internal;
		root /;
	}
<?stt ] ?>

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
<?stt ] ?>'
]

{ #category : #'as yet unclassified' }
GSCWebApplicationSchemeV1 >> templateStoneMonitConfig [
	^ GSCSttTemplate sttString:
'# STONE
check process <?stt= me monitCheckName ?> matching "^/opt/.*/sys/stoned <?stt= me stoneName ?> .*$"
	ONREBOOT START
	MODE ACTIVE
	GROUP <?stt= me appShortCode ?>
	start program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> <?stt= me gsHome ?>/bin/startStone <?stt= me stoneName ?>''" as uid "<?stt= me serverUsername ?>" gid "<?stt= me serverUsername ?>"
	stop program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> <?stt= me gsHome ?>/bin/stopStone <?stt= me stoneName ?>''" as uid "<?stt= me serverUsername ?>" gid "<?stt= me serverUsername ?>"
	if 7 restarts within 10 cycles then stop
	# if totalmem > 700 Mb then alert
	if cpu > 60% for 4 cycles then alert
'
]
