Class {
	#name : #GSCCore,
	#superclass : #Object,
	#instVars : [
		'rootTool',
		'uuidString',
		'filesystemRoot',
		'temporarySudoPassword',
		'sudoPasswortTimestamp',
		'shellSubprocess',
		'isDevelopment',
		'sudoPrompt'
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
		self instance setup
	]
]

{ #category : #shell }
GSCCore >> OLDrunAsyncShell: aString onOutput: aBlock onFinish: aFinishBlock [
	self isShellProcessRunning ifTrue: [ self error: 'Another shell process is running' ].

	self log: aString.

	[
		| isSuccess args |
		
		shellSubprocess := self createOSSUnixSubprocess.
		
		args := { '--return'. '--quiet'. '--echo'. 'never'. '-c'. aString. 'typescript.log' }.
		
		Smalltalk os current isMacOS ifTrue: [
			args := { '-q'. 'typescript.log'. aString }
		].
		
		shellSubprocess
"			shellCommand: aString;"
			command: 'script';
			arguments: args;
			redirectStdout; "automatic default stream creation...above closure."
			redirectStderr;
			redirectStdin;
"			createMissingStandardStreams: true;"
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

{ #category : #'as yet unclassified' }
GSCCore >> autoexpireSudoPassword [

	(sudoPasswortTimestamp isNil or: [ sudoPasswortTimestamp < (DateAndTime now - 2 hours)]) ifTrue: [ 
		temporarySudoPassword := nil ]
]

{ #category : #'as yet unclassified' }
GSCCore >> beDevelopment [
	isDevelopment := true
]

{ #category : #'as yet unclassified' }
GSCCore >> clearSudoPassword [
	temporarySudoPassword := nil
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

{ #category : #accessing }
GSCCore >> filesystemRoot: aString [
	filesystemRoot := aString asPath.
	
	filesystemRoot isRoot ifFalse: [
		filesystemRoot asFileReference ensureCreateDirectory ]
]

{ #category : #'as yet unclassified' }
GSCCore >> getSudoPassword [
	
	self autoexpireSudoPassword.
	
	temporarySudoPassword ifNil: [ self error: 'You need to give the sudo password' ].
	
	"prolong, when in use"
	self timestampSudoPassword.
	
	^ temporarySudoPassword
]

{ #category : #initialization }
GSCCore >> initialize [
	super initialize.

	isDevelopment := false.
	filesystemRoot := Path root.
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
	^ isDevelopment
]

{ #category : #testing }
GSCCore >> isShellProcessRunning [
	^ shellSubprocess notNil and: [ shellSubprocess isRunning ]
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
		shellSubprocess isRunning ifTrue: [ 
			shellSubprocess terminate ].
		shellSubprocess := nil.
	].
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
	^ self runAsyncShell: aString sudo: false onOutput: aBlock onFinish: aFinishBlock
]

{ #category : #shell }
GSCCore >> runAsyncShell: aString sudo: aSudoBoolean onOutput: aBlock onFinish: aFinishBlock [

	self isShellProcessRunning ifTrue: [ 
		self error: 'Another shell process is running' ].

	[ 
	self
		runSshOSSUnixSubprocess: aString
		args: {  }
		sudo: aSudoBoolean
		onLines: aBlock
		onRun: nil
		onFinish: aFinishBlock ]
		forkAt: Processor userInterruptPriority
		named: 'GSC shell process'
]

{ #category : #shell }
GSCCore >> runShellIsSuccess: aString [

	^ self
		  runSshOSSUnixSubprocess: aString
		  args: {  }
		  sudo: false
		  onLines: nil
		  onRun: nil
		  onFinish: nil
]

{ #category : #shell }
GSCCore >> runSshOSSUnixSubprocess: aCommandString args: anArgsCollection sudo: aSudoBoolean onLines: aLinesBlock onRun: aRunBlock onFinish: aFinishBlock [

	| process sudoPassword cmd args envVars lineReader catchFirstSudoPrompt runBlockDone fireRunBlock |

	runBlockDone := false.

	fireRunBlock := [ :proc |
		"do this after the main sudo password has been streamed into the pipe. So that runBlock is ready
		for things like stdin"
		aRunBlock ifNotNil: [
			runBlockDone ifFalse: [
				aRunBlock value: proc.
				runBlockDone := true ]
		].
	].

	aSudoBoolean ifTrue: [
		sudoPassword := self getSudoPassword ].

	process := self createOSSUnixSubprocess.

	envVars := {
		'GS_HOME' -> '/opt/GsDevKit_home'.
		'PATH' -> '/opt/GsDevKit_home/bin:$PATH'
	} asDictionary.

	cmd := 'ssh'.

	args := Array streamContents: [ :a |
		a nextPut: '-ttq'.
		a nextPut: '-oControlMaster=auto'.
		a nextPut: '-oControlPersist=10s'.
		a nextPut: '-oControlPath=/tmp/gscControlMaster.sock'.
		
		a nextPut: 'localhost'.

"Geht nicht gut, weil command nicht serialisiert		a nextPut: 'bash'.
		a nextPut: '--login'.
		a nextPut: '-c'."

		a nextPut: 'stty -echo ;'.
		
		"Used as a container to serialize the real commands"
		a nextPut: 'env'.

		a nextPut: ('SUDO_PROMPT=', sudoPrompt).
		
		envVars keysAndValuesDo: [ :key :value |
			a nextPut: (key, '=', value).
		].

		aSudoBoolean ifTrue: [
			a nextPut: 'sudo'.
			a nextPut: '--preserve-env'.
"			a nextPut: '--prompt='."
"			a nextPut: '--stdin'."
			a nextPut: '--' ].

"		a nextPut: '{'."
		a nextPut: aCommandString.
		a nextPutAll: anArgsCollection.
"		a nextPut: ';'.
		a nextPut: '}'."

	].
	
	self log: (cmd, ' ', (args joinUsing: String space)).
		
	shellSubprocess := process.
	
	process
		command: cmd;
		arguments: args;
		redirectStdout;
		createMissingStandardStreams: true;
		run.
		
	"Sending sudo password into stdin with LF."
"	aSudoBoolean ifTrue: [
		process stdinStream 
			nextPutAll: sudoPassword;
			nextPut: Character lf;
			flush ]."

	lineReader := GSCPipeLinesReadStream new.
	
	"when sudo is involved there is a strange empty newline at the beginning"
	aSudoBoolean ifTrue: [
		lineReader ignoreLeadingNewlines: 1
	].

	catchFirstSudoPrompt := aSudoBoolean.
	
	process waitForExitPollingEvery: (Delay forMilliseconds: 100) doing: [ :proc :outStream :errStream |
		
		lineReader consumePipe: outStream.
		lineReader consumePipe: errStream.

		proc isComplete ifTrue: [ lineReader complete ].

		"If we do not wait for a initial sudo prompt, then we can do that immediately"
		aSudoBoolean ifFalse: [
			fireRunBlock value: proc
		].

		"Always detect sudo prompt"
		lineReader lastLine = sudoPrompt ifTrue: [
			
			proc stdinStream 
				nextPutAll: self getSudoPassword;
				nextPut: Character lf;
				flush.
			lineReader removeLastLine.

			"Detect very first initial sudo prompt, and do stuff right after that"
			catchFirstSudoPrompt ifTrue: [ 
				catchFirstSudoPrompt := false.
				fireRunBlock value: proc
			]

		].
		
		aLinesBlock ifNotNil: [
			lineReader nextLines ifNotEmpty: [ :lines | aLinesBlock value: lines ] ].
	].
	

	"do cleanup stuff in any case"
	process
		waitForExit;
		closeAndCleanStreams.

	"we need to decouple it explicitly here, because the finish block could be
	a cascaded shell process"
	shellSubprocess := nil.
	
	aFinishBlock ifNotNil: [ 
		aFinishBlock value: process isSuccess ].
	
	^ process isSuccess
]

{ #category : #shell }
GSCCore >> runSudoAsyncShell: aString onOutput: aBlock [
	^ self runSudoAsyncShell: aString onOutput: aBlock onFinish: nil
]

{ #category : #shell }
GSCCore >> runSudoAsyncShell: aString onOutput: aBlock onFinish: aFinishBlock [
	
	^ self runAsyncShell: aString sudo: true onOutput: aBlock onFinish: aFinishBlock
]

{ #category : #shell }
GSCCore >> runSudoShellIsSuccess: aString [

	^ self
		  runSshOSSUnixSubprocess: aString
		  args: {  }
		  sudo: true
		  onLines: nil
		  onRun: nil
		  onFinish: nil
]

{ #category : #'as yet unclassified' }
GSCCore >> setSudoPassword: aString [
	temporarySudoPassword := aString.
	
	self timestampSudoPassword
]

{ #category : #'as yet unclassified' }
GSCCore >> setup [
	| rootConf defaultRootConf |

	sudoPrompt := UUID new asString36.

	rootTool := GSCRoot new.
	
	defaultRootConf := GSCRootScheme new buildDefaultConfiguration.
	
	rootConf := GSCConfiguration fromFile: ('/etc/gsc/gsc.conf').
	rootConf presetFrom: defaultRootConf.
	rootConf storeToFile.
	
	rootTool config: rootConf.
	
	self setupServer.
	self setupExample. "TODO: setupFromConfigFiles"
	
	rootTool init.
"	rootTool check."

]

{ #category : #'as yet unclassified' }
GSCCore >> setupExample [
	

	1 to: 5 do: [ :index |
		| app scheme conf |
		scheme := GSCWebApplicationSchemeV1 new.
		conf := GSCConfiguration fromFile: ('/etc/gsc/conf.d/example', index asString, '.conf').
		conf at: 'project:shortCode' put: ('ExampleApp', index asString).
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
"	filesystemRoot := '/tmp/gsc_test_file_root' asPath."

	rootTool add: GSCFolder then: [ :folder |
		folder name: 'Software packages'.

		{'logrotate'. 'ufw'. 'git'. 'htop'. 'unzip'. 'zip'. 'pigz'. 'aptitude'. 'mosh'.
		'cronic'. 'goaccess'. 'lnav'. 'mailutils' "for ngxblocker to send emails" } do: [ :each |
			folder add: GSCAptPackage then: [ :apt |
				apt packageName: each ] ].

		folder add: GSCSnapPackage then: [ :apt |
			apt packageName: 'certbot' ].
	].
	
	rootTool add: GSCNginx.
	
	rootTool add: GSCHaproxy.
	
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

		folder add: GSCShellConsole.
		folder add: GSCGeneralTool then: [ :tool |
			tool actionBlock: [ self clearSudoPassword ].
			tool title: 'reset sudo'
	].	].
]

{ #category : #shell }
GSCCore >> sudoReadFile: aFilePath [

	| lines |
	lines := OrderedCollection new.

	self
		runSshOSSUnixSubprocess: 'cat'
		args: { aFilePath }
		sudo: true
		onLines: [ :newLines | lines addAll: newLines ]
		onRun: nil
		onFinish: nil.

	^ lines joinUsing: String lf
]

{ #category : #shell }
GSCCore >> sudoWriteFile: aFilePath owner: anOwnerString group: aGroupString mode: aModeString with: aString [

	"	self runSudoOSSUnixSubprocess: 'touch """"', aFilePath, '""""' onRun: [ :process |
		process stdinStream
			nextPutAll: aString;
			close
	] onFinish: nil."

	"Ging nicht mit tee, weil es nicht exit gemacht hat"
	self
		runSshOSSUnixSubprocess: 'sed'
		args: { '-n'. ('w ', aFilePath) }
		sudo: true
		onLines: nil
		onRun: [ :process | 
			process stdinStream
				nextPutAll: aString;
				flush;
				close ]
		onFinish: nil.

	aModeString ifNotBlank: [
		self
			runSshOSSUnixSubprocess: 'chmod'
			args: { 
					aModeString.
					aFilePath }
			sudo: true
			onLines: nil
			onRun: nil
			onFinish: nil ].
	
	anOwnerString ifNotBlank: [
		self
			runSshOSSUnixSubprocess: 'chown'
			args: { (anOwnerString, ':', aGroupString). aFilePath }
			sudo: true
			onLines: nil
			onRun: nil
			onFinish: nil ]
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

{ #category : #'as yet unclassified' }
GSCCore >> timestampSudoPassword [
	sudoPasswortTimestamp := DateAndTime now
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
