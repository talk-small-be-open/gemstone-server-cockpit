Class {
	#name : 'GSCSslCertificate',
	#superclass : 'GSCTool',
	#instVars : [
		'domains',
		'certificateName'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'as yet unclassified' }
GSCSslCertificate >> acmeShPath [
	^ (self rootFindTool: GSCAcmeCertificateClient) acmeShPath
]

{ #category : 'accessing' }
GSCSslCertificate >> certificateName [

	^ certificateName ifBlank: [ self domains first ]
]

{ #category : 'accessing' }
GSCSslCertificate >> certificateName: anObject [

	certificateName := anObject
]

{ #category : 'as yet unclassified' }
GSCSslCertificate >> checkMe [
	self beNotNeedsAttention.
	
	(self core fileExists: self keyFilePath) ifFalse: [ self beNeedsAttention: 'PEM certificate file does not exist' ]


]

{ #category : 'as yet unclassified' }
GSCSslCertificate >> doGetCertificate [

"  - name: Ensure port 80 not in use by nginx
    when: resres.useSsl
    service:
      name: nginx
      enabled: yes
      state: stopped"

"	self runShellCommand: ('certbot --standalone -n --agree-tos --email ', self email, ' --cert-name ""', self certificateName, '""  --domains ""', self domainsCommaList, '"" certonly')."




	"Siehe Documentation https://github.com/acmesh-official/acme.sh"



	"!!! TODO! Does not really work. Needs sudo, but stops blabla. Try on CLI first manually"


	| cmd |
	cmd := String streamContents: [ :s |
		s << self acmeShPath.
		s << '--server letsencrypt --issue --nginx '.
		self domains do: [ :each |
			s << ' -d '.
			s << each ]
	].
	self runShellCommand: cmd
]

{ #category : 'as yet unclassified' }
GSCSslCertificate >> doInstallCertificate [
	
	"TODO: Ensure Verzeichnis!!"
	
	| cmd |
	cmd := String streamContents: [ :s |
		s << self acmeShPath.
		s << ' --install-cert '.
		s << '-d '.
		s << self domains first.
		
		s << ' --key-file '.
		s << self keyFilePath.

		s << ' --fullchain-file '.
		s << self fullchainFilePath.
		
		s << ' --reloadcmd "service nginx force-reload"'
	].

	self runShellCommand: cmd
]

{ #category : 'accessing' }
GSCSslCertificate >> domain: aString [
	self domains: { aString }
]

{ #category : 'accessing' }
GSCSslCertificate >> domains [

	^ domains
]

{ #category : 'accessing' }
GSCSslCertificate >> domains: anObject [

	domains := anObject
]

{ #category : 'as yet unclassified' }
GSCSslCertificate >> domainsCommaList [
	^ domains joinUsing: ','
]

{ #category : 'accessing' }
GSCSslCertificate >> email [
	^ self configAt: 'project:email'
]

{ #category : 'as yet unclassified' }
GSCSslCertificate >> fullchainFilePath [
	^ '/etc/gsc/certificates/', self certificateName, '/fullchain.pem'
]

{ #category : 'as yet unclassified' }
GSCSslCertificate >> keyFilePath [
	^ '/etc/gsc/certificates/', self certificateName, '/key.pem'
]

{ #category : 'accessing' }
GSCSslCertificate >> title [
	^ 'SSL Certificate'
]
