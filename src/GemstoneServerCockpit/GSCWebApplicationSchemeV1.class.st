Class {
	#name : #GSCWebApplicationSchemeV1,
	#superclass : #GSCApplicationScheme,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCWebApplicationSchemeV1 >> buildApplicationToolInto: aRootTool [
	| app |

"	app := GSCApplication new.
	app config: config.
	aRootTool addTool: app."
	
"	appConfig := aRootTool config copyWith: config."

	app := aRootTool add: GSCApplication then: [ :a |
		a config: config copy
	].
	
	app add: GSCNginxSite. "then: [ :site |
		site web
	]."

	app add: GSCHaproxySite.
	
	app add: GSCGemstoneStone then: [ :stone |
"		stone add: GSCDummy."
"		stone add: GSCShellCommand then: [ :shell |
			shell cmd: 'ping -t 5 google.com'
		]"
	].
	
	app add: GSCGemstoneGems.
	
	
	app add: GSCAnsibleTasks then: [ :ansible |
		ansible addTasksJson: (config at: 'ansibleTasksJson')
	].
	
	^ app
]

{ #category : #building }
GSCWebApplicationSchemeV1 >> buildDefaultConfiguration [
	
	| conf |
	
	conf := GSCEasyConfigurationBuilder new.

	"Meta - about the project"
	conf project
		shortCode: 'MyWebApp';
		name: 'My web application';
		email: 'andreas.brodbeck@mindclue.ch'.

	"Source code repository"
	conf sourceCode base
		gitUrl: '';
		metacelloName: 'WebApp';
		gitBranch: 'master'.

	"Files in repositories"
	"TODO: In Config so etwas wie eine Vorlage/Kommentar machen können!"
	(conf gitRepositories base)
		path: '/opt/webapp/main';
		url: '';
		branch: 'master'.

"	(conf project gitRepositories school)
		path: '/opt/albus/school';
		url: 'ssh://gitolite@mindclue.dyndns.org:3690/kshp/albus_school_kshp.git';
		branch: 'master'."

	conf gemstone
		version: '3.6.5';
		keyfile: nil.

	conf web
		webRoot: '/opt/webapp/main/web_root';
		useSsl: false;
		appUrlPaths: {'app'. 'admin'};
		domains: {'www.example.com'. };
		workersCount: 3;
		nginxIncludeFile: ''.

	conf mail
		smtpRelayhost: nil.
		
	conf ansibleTasksJson: '[ { } ]'.

	^ conf asGscConfiguration
]

{ #category : #accessing }
GSCWebApplicationSchemeV1 >> ensureDefaultConfig [
	
	super ensureDefaultConfig.
	
	config presetFrom: self buildDefaultConfiguration
	
	"config at: 'gems:count' default: [ 3 ]"
]
