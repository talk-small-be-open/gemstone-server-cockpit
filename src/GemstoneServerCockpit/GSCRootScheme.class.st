Class {
	#name : #GSCRootScheme,
	#superclass : #GSCSchemeBase,
	#category : #'GemstoneServerCockpit-Scheme'
}

{ #category : #'as yet unclassified' }
GSCRootScheme >> buildRootTool [
	self subclassResponsibility
]

{ #category : #building }
GSCRootScheme >> defaultConfigurationBuilder [
	| builder |
	
	builder := super defaultConfigurationBuilder.

	builder server
		username: 'ubuntu';
		adminEmail: '';
		aptPackages: #();
		snapPackages: #().

	builder gemstone
		gsHome: '/opt/GsDevKit_home'.

	builder mail
		smtpRelayhost: nil.
		

	^ builder
]
