Class {
	#name : 'GSCNginx',
	#superclass : 'GSCTool',
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'building' }
GSCNginx >> build [

	self add: GSCAptPackage then: [ :apt |
		apt packageName: 'nginx' ].

	self add: GSCTextFile then: [ :file |
		file
			filePath: ('/etc/nginx/nginx.conf');
			beRootOwned;
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
			beRootOwned;
			contentTemplate: self defaultVhostConfigTemplate
	].

"Dies not work, since sites have not been built yet.	self useSsl ifTrue: ["
	self add: GSCAcmeCertificateClient.
	
	"Install script for NGINX bad bots blocker"
	self add: GSCShellCommand then: [ :shell |
		shell
			title: 'Install bad bots blocker';
			useSudo;
			depotScript: 'install-nginx-ultimate-bad-bot-blocker.sh';
			checkMeBlock: [ :me | (me core fileExists: '/usr/local/sbin/install-ngxblocker') ifFalse: [ me beNeedsAttention: 'Is not installed' ] ]
	].

	"Cron update for NGINX bad bots blocker"
	self add: GSCCronJob then: [ :cron |
		cron
			title: 'Update NGINX bad bots blocker';
			minute: 15;
			hour: 3;
			beRoot;
			command: '/usr/local/sbin/update-ngxblocker -n -q'
	]
	
"TODO
  - name: User {{remoteUser}} is in group www-data (uploaded files permission)
"
]

{ #category : 'as yet unclassified' }
GSCNginx >> defaultVhostConfigTemplate [
	^ GSCSttTemplate tool: self sttString:
'# Reject access with just the IP. We do not want bots or other dark forces to annoy us
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	<?stt me useSsl ifTrue: [ ?>
	#listen 443 ssl http2 default_server;
	#listen [::]:443 ssl http2 default_server;
	# Works only from version >= 1.19.x ssl_reject_handshake on;
	<?stt ] ?>

	server_name _;

	return 444; # Special code from nginx, just fails and does not return anything to caller
}
'
]

{ #category : 'as yet unclassified' }
GSCNginx >> doCheckSyntax [
	self runSudoShellCommand: 'nginx -t'
]

{ #category : 'as yet unclassified' }
GSCNginx >> nginxConfigTemplate [
	^ self scheme templateNginxConfig
		tool: self;
		yourself
]

{ #category : 'as yet unclassified' }
GSCNginx >> nginxSites [
	^ (self rootFindTools: GSCNginxSite)
]

{ #category : 'rendering' }
GSCNginx >> renderBodyOn: html [
"	html iframe
		contents: [ :h | h paragraph: 'HIIII' ]"
]

{ #category : 'accessing' }
GSCNginx >> title [
	^ 'NGINX web server'
]

{ #category : 'as yet unclassified' }
GSCNginx >> useSsl [
	^ self nginxSites anySatisfy: [ :each | each useSsl ]
]
