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

	<?stt me useSsl ifTrue: [ ?>
	listen 443 ssl http2 default_server;
	listen [::]:443 ssl http2 default_server;

	ssl_certificate /etc/letsencrypt/live/<?stt= me appShortCode ?>/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/<?stt= me appShortCode ?>/privkey.pem;
	include /etc/letsencrypt/options-ssl-nginx.conf;
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

	<?stt ] ?>

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
	^ self scheme templateNginxConfig
		tool: self;
		yourself
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
