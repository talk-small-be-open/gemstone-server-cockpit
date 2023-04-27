Class {
	#name : #GSCCore,
	#superclass : #Object,
	#instVars : [
		'rootTool',
		'uuidString',
		'shellProcess'
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
GSCCore >> isShellProcessRunning [
	^ shellProcess notNil and: [ shellProcess isTerminated not ]
]

{ #category : #accessing }
GSCCore >> rootTool [

	^ rootTool
]

{ #category : #shell }
GSCCore >> runAsyncShell: aString logInto: aCollection [
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
					aCollection addAll: read lines.
				]
				onExitDo: [ :process :outStream :errStream  |
					| read | 
					read := outStream upToEnd.
					aCollection addAll: read lines.
					
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

{ #category : #'as yet unclassified' }
GSCCore >> setup [
	self setupExample
]

{ #category : #'as yet unclassified' }
GSCCore >> setupExample [
	rootTool := GSCFolder new.
	
	"TODO: read from config or system"

	1 to: 5 do: [ :index |
		| app scheme conf |
		scheme := GSCWebApplicationSchemeV1 new.
		conf := GSCConfiguration fromFile: ('/etc/gsc/conf.d/example', index asString, '.conf').
		scheme config: conf.
		
		app := scheme buildApplicationToolInto: rootTool.
		
		app init.
		app check.
		
	]
]

{ #category : #'as yet unclassified' }
GSCCore >> setupFromConfigFiles [
	('/etc/gsc/conf.d' asFileReference filesMatching: '*.conf') do: [ :each |
		| conf scheme app |
		conf := GSCConfiguration fromFile: each pathString.

		scheme := conf schemeClass new.
		scheme config: conf.
		
		app := scheme buildApplicationToolInto: rootTool.
		
		app init.
		app check.
		
	]
]
