Class {
	#name : 'GSCRootScheme',
	#superclass : 'GSCSchemeBase',
	#category : 'GemstoneServerCockpit-Scheme',
	#package : 'GemstoneServerCockpit',
	#tag : 'Scheme'
}

{ #category : 'as yet unclassified' }
GSCRootScheme >> buildRootTool [
	| root |

	root := GSCRoot new.
	root scheme: self.
	root gatherFacts.
	root build.
	
	^ root
]

{ #category : 'building' }
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
