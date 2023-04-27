Class {
	#name : #GSCWebApplicationSchemeV1,
	#superclass : #GSCApplicationScheme,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCWebApplicationSchemeV1 >> buildApplicationToolInto: aRootTool [
	| app |
	app := GSCApplication new.
	app config: config.
	aRootTool addTool: app.
	
	app add: GSCGemstoneStone then: [ :stone |
		stone add: GSCDummy.
		stone add: GSCShellCommand then: [ :shell |
			shell cmd: 'ping -t 5 google.com'
		]
	].
	
	app add: GSCGemstoneGems.
	
	app add: GSCNginx.



	^ app
]

{ #category : #building }
GSCWebApplicationSchemeV1 >> buildDefaultConfiguration [
	
	| conf |
	
	conf := GSCEasyConfigurationBuilder new.

	conf project
		installationPath: '/opt/webapp';
		acronym: 'MyWebApp';
		name: 'My web application'.

	conf application
		gitUrl: '';
		gitBranch: 'master'.

	(conf project gitRepositories base)
		path: '/opt/webapp/main';
		url: '';
		branch: 'master'.

"	(conf project gitRepositories school)
		path: '/opt/albus/school';
		url: 'ssh://gitolite@mindclue.dyndns.org:3690/kshp/albus_school_kshp.git';
		branch: 'master'."

	conf server
		username: 'ubuntu';
		adminEmail: '';
		softwarePackages: #(vim).

	conf gemstone
		stoneName: 'webappStone';
		version: '3.6.5';
		keyfile: nil;
		gemPorts: (10001 to: 10005) asArray;
		gsHome: '/opt/GsDevKit_home'.

	conf web
		useSsl: false;
		appUrlPaths: {'app'. 'admin'};
		domains: {'www.example.com'. };
		nginxIncludeFile: ''.

	conf mail
		smtpRelayhost: nil.

	^ conf asGscConfiguration
]

{ #category : #accessing }
GSCWebApplicationSchemeV1 >> ensureDefaultConfig [
	super ensureDefaultConfig.
	
	config at: 'gems:count' default: [ 3 ]
]
