Class {
	#name : #GSCHaproxy,
	#superclass : #GSCTool,
	#instVars : [
		'statusHtml'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCHaproxy >> build [

	self add: GSCAptPackage then: [ :apt |
		apt packageName: 'haproxy' ].
	
	self add: GSCTextFile then: [ :file |
		file
			filePath: self configFilePath;
			contentTemplate: self haproxyConfigTemplate
	].

	self add: GSCSystemService then: [ :service |
		service name: 'haproxy'
	].

"	self add: GSCExternalWebTool then: [ :web |
		web url: '/ha-status' ]"
]

{ #category : #'as yet unclassified' }
GSCHaproxy >> configFilePath [
	^ '/etc/haproxy/haproxy.cfg' asPath
]

{ #category : #rendering }
GSCHaproxy >> doCheckSyntax [
	self core runSudoShellCommand: 'haproxy -c -- ', self configFilePath pathString
]

{ #category : #rendering }
GSCHaproxy >> doViewWebStatus [
	statusHtml := self core sudoReadCommand: 'curl' args: { '--silent'. 'http://127.0.0.1:8404/stats'. }.
]

{ #category : #'as yet unclassified' }
GSCHaproxy >> haproxyConfigTemplate [
	^ GSCSttTemplate tool: self sttString: '
global
		log /dev/log		local0
		log /dev/log		local1 notice
		chroot /var/lib/haproxy
		user haproxy
		group haproxy
		daemon
		unix-bind user root group www-data mode 660

defaults
		log			global
		mode		http
		option	httplog
		option	dontlognull
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
GSCHaproxy >> haproxySiteConfigs [
	^ (self rootFindTools: GSCHaproxySite) collect: [ :each | each haproxyConfigTemplate ]
]

{ #category : #rendering }
GSCHaproxy >> renderBodyOn: html [
	html iframe
		style: 'width: 100%; height: 1000px';
		contents: [ :h | h html: statusHtml ]
]

{ #category : #accessing }
GSCHaproxy >> title [
	^ 'HAproxy balancer'
]
