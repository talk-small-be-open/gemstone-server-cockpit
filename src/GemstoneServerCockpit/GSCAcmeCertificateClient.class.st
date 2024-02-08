Class {
	#name : #GSCAcmeCertificateClient,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCAcmeCertificateClient >> acmeShTemplate [
	| response |
	response := (ZnEasy get: 'https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh').
	
	^ GSCSimpleTemplate source: response entity contents
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
GSCAcmeCertificateClient >> checkMe [
	self beNotNeedsAttention.
	
	(self core runShellIsSuccess: 'type -t acme.sh') ifFalse: [ self beNeedsAttention: 'acme.sh binary not found in path' ]
]

{ #category : #'as yet unclassified' }
GSCAcmeCertificateClient >> doInstall [
	self runShellCommand: '~/acme-sh-installer/acme.sh --install -m ', self serverAdminEmail
]

{ #category : #accessing }
GSCAcmeCertificateClient >> title [
	^ 'acme.sh SSL certificate client'
]
