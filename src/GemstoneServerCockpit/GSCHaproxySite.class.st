Class {
	#name : #GSCHaproxySite,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCHaproxySite >> gemPorts [
	| gemsTool |
	gemsTool := self appFindTool: GSCGemstoneGems.
	
	^ gemsTool gemPorts
]

{ #category : #'as yet unclassified' }
GSCHaproxySite >> haproxyConfigTemplate [
	^ GSCSttTemplate tool: self sttString: '
frontend <?stt= me appShortCode ?>_nginx
		bind unix@/tmp/haproxy_<?stt= me appShortCode ?>.socket
		default_backend <?stt= me appShortCode ?>_gems

		# # Rate limiting, sliding window, see https://www.haproxy.com/blog/four-examples-of-haproxy-rate-limiting/
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
		
#DONT, X-Forwarded-For is already added by nginx		option forwardfor

		option httpchk GET /ping
#		http-check send

		<?stt me gemPorts do: [ :each | ?>
		server gem<?stt= each asString ?> 127.0.0.1:<?stt= each asString ?><?stt ] ?>
'
]

{ #category : #rendering }
GSCHaproxySite >> renderBodyOn: html [
	html paragraph: 'site config file will be included in master config file of nginx.'
]

{ #category : #accessing }
GSCHaproxySite >> title [
	^ 'HAproxy site'
]
