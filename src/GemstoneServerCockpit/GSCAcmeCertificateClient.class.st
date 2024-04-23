Class {
	#name : #GSCAcmeCertificateClient,
	#superclass : #GSCTool,
	#instVars : [
		'acmeShScript'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCAcmeCertificateClient >> acmeShPath [
	^ self serverUserHome, '/.acme.sh/acme.sh'
]

{ #category : #accessing }
GSCAcmeCertificateClient >> acmeShTemplate [

	self cacheAcmeShScript.
		
	^ GSCSimpleTemplate source: acmeShScript
]

{ #category : #accessing }
GSCAcmeCertificateClient >> build [
	self add: GSCTextFile then: [ :file |
		file
			title: 'acme.sh script file';
			filePath: self serverUserHome, '/acme-sh-installer/acme.sh';
			beUserOwned;
			mode: 'u=rwx,g=rw';
			contentTemplate: self acmeShTemplate
	]
]

{ #category : #'as yet unclassified' }
GSCAcmeCertificateClient >> cacheAcmeShScript [
	acmeShScript ifBlank: [ self downloadAcmeShScript ]
]

{ #category : #'as yet unclassified' }
GSCAcmeCertificateClient >> checkMe [
	self beNotNeedsAttention.
	
	(self core runShellIsSuccess: 'file -E ', self acmeShPath) ifFalse: [ self beNeedsAttention: 'acme.sh binary not installed' ]
]

{ #category : #'as yet unclassified' }
GSCAcmeCertificateClient >> doInstall [
	self runBashScript: ('
cd ', self serverUserHome, '/acme-sh-installer
./acme.sh --install -m ', self serverAdminEmail)
]

{ #category : #accessing }
GSCAcmeCertificateClient >> downloadAcmeShScript [
	| response |
	response := (ZnEasy get: 'https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh').

	response isSuccess ifTrue: [ acmeShScript := response entity contents ].
]

{ #category : #accessing }
GSCAcmeCertificateClient >> title [
	^ 'acme.sh SSL certificate client'
]
