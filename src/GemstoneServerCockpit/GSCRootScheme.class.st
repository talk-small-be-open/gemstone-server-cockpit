Class {
	#name : #GSCRootScheme,
	#superclass : #GSCSchemeBase,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCRootScheme >> buildDefaultConfiguration [
	
	| conf |
	
	conf := GSCEasyConfigurationBuilder new.

	conf server
		username: 'ubuntu';
		installationPath: '/opt/webapp';
		adminEmail: '';
		softwarePackages: #(vim).

	conf gemstone
		gsHome: '/opt/GsDevKit_home'.
		

	^ conf asGscConfiguration
]
