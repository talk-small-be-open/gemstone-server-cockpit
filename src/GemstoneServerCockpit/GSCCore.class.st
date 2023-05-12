Class {
	#name : #GSCCore,
	#superclass : #Object,
	#instVars : [
		'rootTool',
		'uuidString',
		'filesystemRoot',
		'temporarySudoPassword',
		'sudoPasswortTimestamp',
		'shellSubprocess'
	],
	#classVars : [
		'Instance'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCCore class >> enableAutomation [
	Smalltalk addToStartUpList: self.
"	Smalltalk addToShutDownList: self"
]

{ #category : #initialization }
GSCCore class >> initialize [
	super initialize.
	self enableAutomation
]

{ #category : #actions }
GSCCore class >> install [
	self instance install
]

{ #category : #accessing }
GSCCore class >> instance [
	Instance ifNil: [ Instance := self new ].
	^ Instance
]

{ #category : #'system startup' }
GSCCore class >> startUp: isComingUp [
	isComingUp ifTrue: [
		"Automatic read in the config files on the server"
		self instance setupFromConfigFiles
	]
]

{ #category : #'as yet unclassified' }
GSCCore >> autoexpireSudoPassword [
	sudoPasswortTimestamp ifNil: [ ^ self ].
	(sudoPasswortTimestamp < (DateAndTime now - 2 hours)) ifTrue: [ 
		temporarySudoPassword := nil ]
]

{ #category : #shell }
GSCCore >> createOSSUnixSubprocess [
	| process gsHome path |
	
	gsHome := (rootTool configAt: 'gemstone:gsHome') ifBlank: [ '/opt/GsDevKit_home' ].
	path := Smalltalk os environment at: 'PATH'.
	
	process := OSSUnixSubprocess new
		environmentAt: 'GS_HOME' put: gsHome;
		environmentAt: 'PATH' put: (gsHome, '/bin:', path);
		yourself.
	
	^ process
]

{ #category : #accessing }
GSCCore >> filesystemRoot [

	^ filesystemRoot
]

{ #category : #'as yet unclassified' }
GSCCore >> getSudoPassword [
	
	self autoexpireSudoPassword.
	
	temporarySudoPassword ifNil: [ self error: 'You need to give the sudo password' ].
	
	^ temporarySudoPassword
]

{ #category : #actions }
GSCCore >> install [
	self installSeasideComponents.
	self setup.
]

{ #category : #'as yet unclassified' }
GSCCore >> installSeasideComponents [
	| app appPath |

	appPath := self instanceId asString.

	app := WAAdmin 
		register: GSCMainCockpit
		asApplicationAt: appPath.

	app addLibrary: GSCWaFileLibrary.
"	app configuration addParent: WAEmailConfiguration instance."

	app exceptionHandler: WADebugErrorHandler.

	WAAdmin defaultDispatcher defaultName: appPath
]

{ #category : #'as yet unclassified' }
GSCCore >> instanceId [
	uuidString ifNil: [ uuidString := UUID new asString36 ].
	^ uuidString
]

{ #category : #testing }
GSCCore >> isDevelopment [
	"TODO"
	^ true
]

{ #category : #testing }
GSCCore >> isShellProcessRunning [
	^ shellSubprocess notNil and: [ shellSubprocess isComplete not ]
]

{ #category : #testing }
GSCCore >> isSudoPasswordSet [
	self autoexpireSudoPassword.
	^ temporarySudoPassword notBlank
]

{ #category : #'as yet unclassified' }
GSCCore >> killShellProcess [
	"Kill the OS subprocess. The Pharo process then will terminate automatically"
	shellSubprocess ifNotNil: [
		shellSubprocess terminate ].
]

{ #category : #logging }
GSCCore >> log: aString [
	Transcript crShow: aString
]

{ #category : #helpers }
GSCCore >> realPathForFile: aFileReferenceOrString [
	| fr |
	fr := aFileReferenceOrString asFileReference.
	
	"OPTIMIZE: I think there is a onliner for that, but did not find it"
	filesystemRoot isRoot ifFalse: [
		| relative |
		relative := fr relativeTo: Path root.
		^ (filesystemRoot resolvePath: relative) asFileReference.
	].

	^ fr
]

{ #category : #accessing }
GSCCore >> rootTool [

	^ rootTool
]

{ #category : #shell }
GSCCore >> runAsyncShell: aString onOutput: aBlock [
	^ self runAsyncShell: aString onOutput: aBlock onFinish: nil
]

{ #category : #shell }
GSCCore >> runAsyncShell: aString onOutput: aBlock onFinish: aFinishBlock [
	self isShellProcessRunning ifTrue: [ self error: 'Another shell process is running' ].

	self log: aString.

	[
		| isSuccess |
		
		shellSubprocess := self createOSSUnixSubprocess.
		shellSubprocess
			shellCommand: aString;
			redirectStdout; "automatic default stream creation...above closure."
			redirectStderr;
			createMissingStandardStreams: true;
			runAndWaitPollingEvery: (Delay forMilliseconds: 500)
				doing: [ :process :outStream :errStream |  
					outStream upToEnd ifNotBlank: [ :output |
						aBlock value: output lines ].
					errStream upToEnd ifNotBlank: [ :output |
						aBlock value: output lines ].
				]
				onExitDo: [ :process :outStream :errStream  |
"					| read | 
					read := outStream upToEnd.
					aBlock value: read lines."
					
					process closeAndCleanStreams.
				].

				isSuccess := shellSubprocess isSuccess.
				shellSubprocess := nil.
				
				aFinishBlock ifNotNil: [ 
					aFinishBlock value: isSuccess ]

			] forkAt: Processor userInterruptPriority named: 'GSC shell process'
]

{ #category : #shell }
GSCCore >> runShellIsSuccess: aString [ 

	self log: aString.
	
	^ self createOSSUnixSubprocess
"		command: aString;"
		shellCommand: aString;
		runAndWait;
		isSuccess
]

{ #category : #shell }
GSCCore >> runSudoAsyncShell: aString onOutput: aBlock [
	^ self runSudoAsyncShell: aString onOutput: aBlock onFinish: nil
]

{ #category : #shell }
GSCCore >> runSudoAsyncShell: aString onOutput: aBlock onFinish: aFinishBlock [
	| sudoPassword cmd args |
	
	self isShellProcessRunning ifTrue: [ self error: 'Another shell process is running' ].

	sudoPassword := self getSudoPassword.

	cmd := 'sudo'.
	args := { '--preserve-env'. '--prompt='. '--stdin'. '--'. 'sh'. '-c'. aString. }.

	self log: (cmd, (args joinUsing: String space)).

	[
		| isSuccess |
		shellSubprocess := self createOSSUnixSubprocess.
		shellSubprocess
			command: cmd;
			arguments: args;
"			defaultReadStreamCreationBlock: [OSSVMProcess vmProcess systemAccessor makeNonBlockingPipe];"
			redirectStdout;
			redirectStderr;
			redirectStdin;
			createMissingStandardStreams: true;
			run.

		shellSubprocess stdinStream
			nextPutAll: sudoPassword;
			nextPut: Character lf;
			flush.
"			close."

		shellSubprocess waitForExitPollingEvery: (Delay forMilliseconds: 500) doing: [ :proc :outStream :errStream |  
			outStream upToEnd ifNotBlank: [ :output |
				aBlock value: output lines ].
			errStream upToEnd ifNotBlank: [ :output |
				aBlock value: output lines ].
		].

"		output := process stdoutStream upToEnd.
		aCollection addAll: output lines."
		
		shellSubprocess closeAndCleanStreams.
		isSuccess := shellSubprocess isSuccess.
		shellSubprocess := nil.
		
		aFinishBlock ifNotNil: [ 
			aFinishBlock value: isSuccess ].
		

	] forkAt: Processor userInterruptPriority named: 'GSC shell process'
]

{ #category : #shell }
GSCCore >> runSudoShellIsSuccess: aString [ 
	| process sudoPassword cmd args |

	sudoPassword := self getSudoPassword.

	process := self createOSSUnixSubprocess.

	cmd := 'sudo'.
	args := { '--preserve-env'. '--prompt='. '--stdin'. '--'. 'sh'. '-c'. aString. }.
	self log: (cmd, (args joinUsing: String space)).

		
	process
		command: cmd;
		arguments: args;
		createMissingStandardStreams: true;
		run.
		
	process stdinStream 
		nextPutAll: sudoPassword;
		close.

	process
		waitForExit;
		closeAndCleanStreams.

	^ process isSuccess
]

{ #category : #'as yet unclassified' }
GSCCore >> setSudoPassword: aString [
	temporarySudoPassword := aString.
	
	sudoPasswortTimestamp := DateAndTime now

]

{ #category : #'as yet unclassified' }
GSCCore >> setup [
	| rootConf defaultRootConf |
	rootTool := GSCRoot new.
	
	defaultRootConf := GSCRootScheme new buildDefaultConfiguration.
	
	rootConf := GSCConfiguration fromFile: ('/etc/gsc/gsc.conf').
	rootConf presetFrom: defaultRootConf.
	rootConf storeToFile.
	
	rootTool config: rootConf.
	
	self setupServer.
	self setupExample.
	
	rootTool init.
	rootTool check.

]

{ #category : #'as yet unclassified' }
GSCCore >> setupExample [
	

	1 to: 5 do: [ :index |
		| app scheme conf |
		scheme := GSCWebApplicationSchemeV1 new.
		conf := GSCConfiguration fromFile: ('/etc/gsc/conf.d/example', index asString, '.conf').
		conf at: 'project:name' put: ('Example Webapp ', index asString).

		scheme config: conf.
		
		app := scheme buildApplicationToolInto: rootTool.
		
	]
]

{ #category : #'as yet unclassified' }
GSCCore >> setupFromConfigFiles [
	| confDir |
	confDir := '/etc/gsc/conf.d' asFileReference.
	confDir exists ifTrue: [
		(confDir filesMatching: '*.conf') do: [ :each |
			| conf scheme app |
			conf := GSCConfiguration fromFile: each pathString.

			scheme := conf schemeClass new.
			scheme config: conf.
			
			app := scheme buildApplicationToolInto: rootTool.
			
	]]
]

{ #category : #'as yet unclassified' }
GSCCore >> setupServer [
	"TODO: DEV"
	filesystemRoot := '/tmp/gsc_test_file_root' asPath.

	filesystemRoot asFileReference ensureCreateDirectory.

	rootTool add: GSCFolder then: [ :folder |
		folder name: 'APT packages'.

		folder add: GSCAptPackage then: [ :apt |
			apt packageName: 'unzip' ].
		folder add: GSCAptPackage then: [ :apt |
			apt packageName: 'git' ].
	].
	
	rootTool add: GSCNginx.
	
	rootTool add: GSCMonit.
	
	rootTool add: GSCGsDevKit.

	rootTool add: GSCAnsibleTasks then: [ :ansible |
		ansible addTasksJson: '
[
    {
        "name": "Set timezone to Switzerland",
        "timezone": {
            "name": "Europe/Zurich"
        }
    },
    {
        "name": "Add user group",
        "group": {
            "name": "{{remoteUser}}"
        }
    },
    {
        "name": "Add user",
        "user": {
            "name": "{{remoteUser}}",
            "group": "adm",
            "groups": "sudo, {{remoteUser}}",
            "shell": "/bin/bash"
        }
    }
]
'
	].

	rootTool add: GSCFolder then: [ :folder |
		folder name: 'Utilities'.

		folder add: GSCShellConsole
	].
]

{ #category : #helpers }
GSCCore >> temporaryFolder [
	^ '/tmp' asFileReference
]

{ #category : #helpers }
GSCCore >> temporaryUniqueFile: anExtensionString [
	| uuid file |
	uuid := UUID new.
	
	file := self temporaryFolder / (uuid greaseString, '.', anExtensionString).
	
	^ file
]

{ #category : #writing }
GSCCore >> writeLineToShellProcess: aString [
	shellSubprocess stdinStream
		nextPutAll: aString;
"		cr;"
		nextPut: Character lf;
		flush
]

{ #category : #writing }
GSCCore >> writeToShellProcess: aString [
	shellSubprocess stdinStream
		nextPutAll: aString;
		flush
]
