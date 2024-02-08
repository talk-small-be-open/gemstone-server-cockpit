Class {
	#name : #GSCSslCertificate,
	#superclass : #GSCTool,
	#instVars : [
		'domains',
		'certificateName'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCSslCertificate >> acmeShPath [
	^ (self rootFindTool: GSCAcmeCertificateClient) acmeShPath
]

{ #category : #accessing }
GSCSslCertificate >> certificateName [

	^ certificateName ifBlank: [ self domains first ]
]

{ #category : #accessing }
GSCSslCertificate >> certificateName: anObject [

	certificateName := anObject
]

{ #category : #'as yet unclassified' }
GSCSslCertificate >> checkMe [
	self beNotNeedsAttention.
	
	(self core fileExists: self pemFilePath) ifFalse: [ self beNeedsAttention: 'PEM certificate file does not exist' ]


]

{ #category : #'as yet unclassified' }
GSCSslCertificate >> doGetCertificate [

"  - name: Ensure port 80 not in use by nginx
    when: resres.useSsl
    service:
      name: nginx
      enabled: yes
      state: stopped"

"	self runShellCommand: ('certbot --standalone -n --agree-tos --email ', self email, ' --cert-name ""', self certificateName, '""  --domains ""', self domainsCommaList, '"" certonly')."

	"Siehe https://github.com/acmesh-official/acme.sh"

	| cmd |
	cmd := String streamContents: [ :s |
		s << self acmeShPath.
		s << ' --issue --nginx '.
		self domains do: [ :each |
			s << ' -d '.
			s << each ]
	].
	self runShellCommand: cmd
]

{ #category : #accessing }
GSCSslCertificate >> domain: aString [
	self domains: { aString }
]

{ #category : #accessing }
GSCSslCertificate >> domains [

	^ domains
]

{ #category : #accessing }
GSCSslCertificate >> domains: anObject [

	domains := anObject
]

{ #category : #'as yet unclassified' }
GSCSslCertificate >> domainsCommaList [
	^ domains joinUsing: ','
]

{ #category : #accessing }
GSCSslCertificate >> email [
	^ self configAt: 'project:email'
]

{ #category : #'as yet unclassified' }
GSCSslCertificate >> pemFilePath [
	^ '/etc/letsencrypt/live/', self certificateName, '/fullchain.pem'
]

{ #category : #accessing }
GSCSslCertificate >> title [
	^ 'SSL Certificate'
]
