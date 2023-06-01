Class {
	#name : #GSCCertbotCertificates,
	#superclass : #GSCTool,
	#instVars : [
		'domains',
		'certificateName'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCCertbotCertificates >> certificateName [

	^ certificateName
]

{ #category : #accessing }
GSCCertbotCertificates >> certificateName: anObject [

	certificateName := anObject
]

{ #category : #'as yet unclassified' }
GSCCertbotCertificates >> checkMe [
	self beNotNeedsAttention.
	
	(self core fileExists: self pemFilePath) ifFalse: [ self beNeedsAttention: 'PEM certificate file does not exist' ]


]

{ #category : #'as yet unclassified' }
GSCCertbotCertificates >> doGetCertificate [

"  - name: Ensure port 80 not in use by nginx
    when: resres.useSsl
    service:
      name: nginx
      enabled: yes
      state: stopped"

	self runShellCommand: ('certbot --standalone -n --agree-tos --email ', self email, ' --cert-name "', self certificateName, '"  --domains "', self domainsCommaList, '" certonly').

]

{ #category : #accessing }
GSCCertbotCertificates >> domain: aString [
	self domains: { aString }
]

{ #category : #accessing }
GSCCertbotCertificates >> domains [

	^ domains
]

{ #category : #accessing }
GSCCertbotCertificates >> domains: anObject [

	domains := anObject
]

{ #category : #'as yet unclassified' }
GSCCertbotCertificates >> domainsCommaList [
	^ domains joinUsing: ','
]

{ #category : #accessing }
GSCCertbotCertificates >> email [
	^ self configAt: 'project:email'
]

{ #category : #'as yet unclassified' }
GSCCertbotCertificates >> pemFilePath [
	^ '/etc/letsencrypt/live/', self certificateName, '/fullchain.pem'
]
