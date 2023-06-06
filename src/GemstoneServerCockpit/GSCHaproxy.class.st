Class {
	#name : #GSCHaproxy,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCHaproxy >> build [

	self add: GSCAptPackage then: [ :apt |
		apt packageName: 'haproxy' ].
	
	self add: GSCTextFile then: [ :file |
		file
			filePath: ('/etc/haproxy/haproxy.cfg');
			contentTemplate: self haproxyConfigTemplate
	].

	self add: GSCSystemService then: [ :service |
		service name: 'haproxy'
	].


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

		# For debugging on the commandline with socket access (see http://cbonte.github.io/haproxy-dconv/1.8/management.html#9.3)
		#stats socket /var/run/haproxy.sock mode 600 level admin
    #stats timeout 2m

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

# # Pseudo backend to store rates
# backend Abuse
#     # stick-table type ip size 100K expire 30m store gpc0,http_req_rate(10s)
# 		# better: IP taken from XFF
# 		stick-table type integer size 100K expire 30m store gpc0,http_req_rate(10s)

<?stt me haproxySiteConfigs do: [ :each | ?>
<?stt= each contentString ?>
<?stt ] ?>'
]

{ #category : #'as yet unclassified' }
GSCHaproxy >> haproxySiteConfigs [
	^ (self rootFindTools: GSCHaproxySite) collect: [ :each | each haproxyConfigTemplate ]
]

{ #category : #accessing }
GSCHaproxy >> title [
	^ 'HAproxy balancer'
]
