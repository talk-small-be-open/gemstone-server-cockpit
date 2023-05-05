Class {
	#name : #GSCCore,
	#superclass : #Object,
	#instVars : [
		'rootTool',
		'uuidString',
		'shellProcess',
		'filesystemRoot',
		'temporarySudoPassword'
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

{ #category : #accessing }
GSCCore >> filesystemRoot [

	^ filesystemRoot
]

{ #category : #'as yet unclassified' }
GSCCore >> getSudoPassword [
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
	^ shellProcess notNil and: [ shellProcess isTerminated not ]
]

{ #category : #testing }
GSCCore >> isSudoPasswordSet [
	^ temporarySudoPassword notBlank
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
GSCCore >> runAsyncShell: aString onLog: aBlock [
	self isShellProcessRunning ifTrue: [ self error: 'Another shell process is running' ].

	shellProcess := [
		OSSUnixSubprocess new
	"		command: aString;"
			shellCommand: aString;
	"		arguments: (Array with: Smalltalk image imagePath);"
	"		defaultWriteStreamCreationBlock: [ OSSVMProcess vmProcess systemAccessor makeNonBlockingPipe ];"
			redirectStdout; "automatic default stream creation...above closure."
	"		redirectStderrTo: '/tmp/stderrFile.txt' asFileReference writeStream;"
			redirectStderr;
	"		createMissingStandardStreams: false;" "therefore won't create stdin stream"
	"		workingDirectory: '/home';" "set working directory for child"
	"		environmentAt: 'HOME' put: '/tmp/home';"
	"		addAllEnvVariablesFromParentWithoutOverride;" "we will inherit then all but $HOME"
			runAndWaitPollingEvery: (Delay forMilliseconds: 500)
				doing: [ :process :outStream :errStream |  
					| read | 
					read := outStream upToEnd.
					aBlock value: read lines.
				]
				onExitDo: [ :process :outStream :errStream  |
"					| read | 
					read := outStream upToEnd.
					aBlock value: read lines."
					
					process closeAndCleanStreams.
				]
			] forkAt: Processor userInterruptPriority. 
]

{ #category : #shell }
GSCCore >> runShellIsSuccess: aString [ 
	^ OSSUnixSubprocess new
"		command: aString;"
		shellCommand: aString;
		runAndWait;
		isSuccess
]

{ #category : #shell }
GSCCore >> runSudoAsyncShell: aString onLog: aBlock [
	| sudoPassword output |
	
	self isShellProcessRunning ifTrue: [ self error: 'Another shell process is running' ].

	sudoPassword := self getSudoPassword.

	shellProcess := [
		| process |
		process := OSSUnixSubprocess new.
		process
			shellCommand: ('sudo -S ', aString);
			redirectStdout;
			redirectStderr;
			createMissingStandardStreams: true;
			run.

		process stdinStream
			nextPutAll: sudoPassword;
			close.

		process waitForExitPollingEvery: (Delay forMilliseconds: 500) doing: [ :proc :outStream :errStream |  
			| out | 
			out := outStream upToEnd.
			aBlock value: out lines.
		].

"		output := process stdoutStream upToEnd.
		aCollection addAll: output lines."
		
		process closeAndCleanStreams.
			
	] forkAt: Processor userInterruptPriority. 
]

{ #category : #shell }
GSCCore >> runSudoShellIsSuccess: aString [ 
	| process sudoPassword |

	sudoPassword := self getSudoPassword.

	process := OSSUnixSubprocess new.
		
		process
			shellCommand: ('sudo -S ', aString);
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
	temporarySudoPassword := aString

]

{ #category : #'as yet unclassified' }
GSCCore >> setup [
	| rootConf |
	rootTool := GSCRoot new.
	
	rootConf := GSCConfiguration fromFile: ('/etc/gsc/gsc.conf').
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
	]
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
