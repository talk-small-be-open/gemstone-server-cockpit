Class {
	#name : #GSCRootScheme,
	#superclass : #GSCSchemeBase,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCRootScheme >> buildRootTool [
	| root |

	root := GSCRoot new.
	root scheme: self.
	root build.

	^ root
]

{ #category : #building }
GSCRootScheme >> defaultConfigurationBuilder [
	| builder |
	
	builder := super defaultConfigurationBuilder.

	builder server
		username: 'ubuntu';
		adminEmail: '';
		aptPackages: #(vim);
		snapPackages: #().

	builder gemstone
		gsHome: '/opt/GsDevKit_home'.
		

	^ builder
]
