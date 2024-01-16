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
		'sudoPrompt',
		'subprocessTailLines',
		'subprocessCommandLabel'
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
GSCCore >> applicationUrl [
	^ self seasideApplication url
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
	
	gsHome := rootTool gemstoneGsHome pathString.
	path := Smalltalk os environment at: 'PATH'.
	
	process := OSSUnixSubprocess new
		environmentAt: 'GS_HOME' put: gsHome;
		environmentAt: 'PATH' put: (gsHome, '/bin:', path);
		yourself.
	
	^ process
]

{ #category : #shell }
GSCCore >> dirExists: aPathString [
	^ self runSudoShellIsSuccess: ('test -d "', (aPathString asPath pathString), '"')
]

{ #category : #'as yet unclassified' }
GSCCore >> ensureWebserver [
	"Webserver starten"
	| webserver |
	webserver := ZnZincServerAdaptor default.
	(webserver isNil or: [ webserver isRunning not ]) ifTrue: [
		self startWebserver ]
]

{ #category : #shell }
GSCCore >> fileExists: aPathString [
	^ self runSudoShellIsSuccess: ('test -f "', (aPathString asPath pathString), '"')
]

{ #category : #accessing }
GSCCore >> filesystemRoot [

	^ filesystemRoot
]

{ #category : #accessing }
GSCCore >> filesystemRoot: aString [
	filesystemRoot := aString asPath.
	
	filesystemRoot isRoot ifFalse: [
		self sudoEnsureDirectory: filesystemRoot owner: self serverUsername group: self serverUsername mode: 'u=rwx,g=rwx,o=rx'
	]
]

{ #category : #shell }
GSCCore >> forkShellBlock: aBlock [

	self isShellProcessRunning ifTrue: [ 
		self error: 'Another shell process is running'. ^ self ].

	aBlock
		forkAt: Processor userInterruptPriority
		named: 'GSC shell process'
]

{ #category : #'as yet unclassified' }
GSCCore >> getSudoPassword [
	
	self autoexpireSudoPassword.
	
	temporarySudoPassword ifNil: [ GSCMissingSudoPassword signal: 'You need to give the sudo password' ].
	
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

	self ensureWebserver.

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
GSCCore >> isShellProcessPresent [
	^ shellSubprocess notNil
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
		shellSubprocess isRunning ifTrue: [ 
			shellSubprocess terminate ].
		shellSubprocess := nil.
	].
]

{ #category : #logging }
GSCCore >> log: aString [
	Transcript crShow: aString
]

{ #category : #'as yet unclassified' }
GSCCore >> readCommand: aCommand [
	^ self readCommand: aCommand args: #()
]

{ #category : #'as yet unclassified' }
GSCCore >> readCommand: aCommand args: aCollection [
	^ self readCommand: aCommand sudo: false args: aCollection
]

{ #category : #shell }
GSCCore >> readCommand: aCommand sudo: aBoolean args: aCollection [

	| lines |
	lines := OrderedCollection new.

	self
		runSshOSSUnixSubprocess: aCommand
		args: aCollection
		sudo: aBoolean
		onLines: [ :newLines | lines addAll: newLines ]
		onRun: nil
		onFinish: nil.

	^ lines joinUsingLf
]

{ #category : #helpers }
GSCCore >> realPathForFile: aFileReferenceOrString [
	| path |
	path := aFileReferenceOrString asPath.
	
	"OPTIMIZE: I think there is a onliner for that, but did not find it"
	filesystemRoot isRoot ifFalse: [
		"check if already on that prefixed path. Not 100% if we should do that here.
		But this avoids multi-prefixed pathes, operating with pathes"
		(filesystemRoot contains: path) ifFalse: [
			| relative |
			relative := path relativeTo: Path root.
			^ (filesystemRoot resolvePath: relative) asPath ].
	].

	^ path
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

	self forkShellBlock: [
		self
			runSshOSSUnixSubprocess: aString
			args: {  }
			sudo: aSudoBoolean
			onLines: aBlock
			onRun: nil
			onFinish: aFinishBlock
	]
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

	| process sudoPassword cmd args envVars lineReader catchFirstSudoPrompt runBlockDone fireRunBlock linesBlock |

	self isShellProcessRunning ifTrue: [ self error: 'Another shell process is running.' ].

	subprocessCommandLabel := aCommandString.
	
	runBlockDone := false.

	linesBlock := aLinesBlock ifNil: [ [ :lines | Transcript << lines ] ].

	subprocessTailLines ifNil: [
		subprocessTailLines := OrderedCollection new ].

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
		'GS_HOME' -> rootTool gemstoneGsHome pathString.
		'PATH' -> (rootTool gemstoneGsHome pathString, '/bin:$PATH').
		'TERM' -> 'dumb'. "Some applications like 'service' have complained about non-capable terminal. We explicitely set to dumb."
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

		"Prevent the input being echoed as output"
		a nextPut: 'stty icanon isig iexten iutf8 -echo eof ^D intr ^C ;'.
		
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

			(Delay forMilliseconds: 110) wait.
	
			"Detect very first initial sudo prompt, and do stuff right after that"
			catchFirstSudoPrompt ifTrue: [ 
				catchFirstSudoPrompt := false.
				fireRunBlock value: proc
			]

		].
		
		lineReader nextLines ifNotEmpty: [ :lines |
			subprocessTailLines addAll: lines.
			subprocessTailLines := subprocessTailLines lastAtMost: 200.
			linesBlock value: lines ]
	].
	

	"do cleanup stuff in any case"
	process
"vermutlich verantwortlich für nicht stoppende Prozesse, deadlocks. nicht nötig nochmals:		waitForExit;"
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
	
	self runAsyncShell: aString sudo: true onOutput: aBlock onFinish: aFinishBlock
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
GSCCore >> seasideApplication [
	^ WAAdmin defaultDispatcher handlerAt: self instanceId asString
]

{ #category : #shell }
GSCCore >> serverUsername [
	^ self rootTool configAt: 'server:username'
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

	defaultRootConf := GSCRootScheme new buildDefaultConfiguration.
	
	"Get root config from external file"
	rootConf := GSCConfiguration fromFile: ('/etc/gsc/gsc.conf').

	"pre-load with the default configuration"
	rootConf presetFrom: defaultRootConf.
	
	"Store it back to the file (could have added some new default values)"
"?Why	rootConf storeToFile."
	
	"Create the root node of the tool tree"
	rootTool := GSCRoot new.
	rootTool config: rootConf.
	rootTool build.
		
	"Do soms stuff inside Pharo to set things right"
	self setupPharo.
	
	"build the tool tree according to the config"
	"Build tools for the Linux server infrastructure"
	self setupServer.
	
	"Build tools for the one or many applications, taken from their conf files"
	self setupApplicationsFromConfigFiles.
	
	"self setupExample."
	
	"Initialize the tool tree, after the instatiation of the whole tree"
	rootTool init.
"	rootTool check."

]

{ #category : #'as yet unclassified' }
GSCCore >> setupApplicationsFromConfigFiles [
	| confDir |
	confDir := (GSCCore instance realPathForFile: '/etc/gsc/applications') asFileReference.
	confDir exists ifTrue: [
		(confDir filesMatching: '*.conf') do: [ :each |
			| conf scheme app |
			conf := GSCConfiguration fromFile: each pathString.

			scheme := conf createScheme.
			
			app := scheme buildApplicationToolInto: rootTool.
			
	]]
]

{ #category : #'as yet unclassified' }
GSCCore >> setupExampleApplications [
	

	1 to: 5 do: [ :index |
		| app scheme conf |
		scheme := GSCWebApplicationSchemeV1 new.
		conf := GSCConfiguration fromFile: ('/etc/gsc/applications/example', index asString, '.conf').
		conf at: 'project:shortCode' put: ('ExampleApp', index asString).
		conf at: 'project:name' put: ('Example Webapp ', index asString).

		scheme config: conf.
		
		app := scheme buildApplicationToolInto: rootTool.
		
	]
]

{ #category : #'as yet unclassified' }
GSCCore >> setupPharo [
	GSCHtmlCanvas selectAsDefault
]

{ #category : #'as yet unclassified' }
GSCCore >> setupServer [
	"TODO: DEV"
"	filesystemRoot := '/tmp/gsc_test_file_root' asPath."

	rootTool add: GSCFolder then: [ :folder |
		folder name: 'Server software'.

		"hardcoded apt packages for the server setup"
		{'logrotate'. 'ufw'. 'git'. 'htop'. 'unzip'. 'zip'. 'pigz'. 'aptitude'. 'mosh'.
		'cronic'. 'goaccess'. 'lnav'. 'mailutils' "for ngxblocker to send emails" } do: [ :each |
			folder add: GSCAptPackage then: [ :apt |
				apt packageName: each ] ].
		
		"additional apt packages from the config"
		(rootTool configAt: 'server:aptPackages') do: [ :each |
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

{ #category : #'as yet unclassified' }
GSCCore >> startWebserver [
	"Webserver starten"
	| port |
	port := 8650 "Looks like: 8GSC".
	ZnZincServerAdaptor startOn: port.

]

{ #category : #accessing }
GSCCore >> subprocessCommandLabel [

	^ subprocessCommandLabel
]

{ #category : #accessing }
GSCCore >> subprocessTailLines [

	^ subprocessTailLines
]

{ #category : #shell }
GSCCore >> sudoAsyncWriteFile: aFilePath owner: anOwnerString group: aGroupString mode: aModeString with: aString then: aBlock [

	"	self runSudoOSSUnixSubprocess: 'touch """"', aFilePath, '""""' onRun: [ :process |
		process stdinStream
			nextPutAll: aString;
			close
	] onFinish: nil."

	self forkShellBlock: [
		| path fileContent endsWithLf |
		path := aFilePath asPath pathString.
		fileContent := aString withUnixLineEndings.
		endsWithLf := fileContent last = Character lf.

		"Ging nicht mit tee, weil es nicht exit gemacht hat"
	"		runSshOSSUnixSubprocess: 'sed'
			args: { '-n'. ('''w ', path, '''') }"
"nicht zuverlässig, hängt			runSshOSSUnixSubprocess: 'tee'
			args: { path }"

		"sed
		- filter out NULL chars (dont know where the hell they are appended from!)
		- write to file
		"

		self
			runSshOSSUnixSubprocess: 'sed'
			args: { '-n'. ('''s/\x0//g; w ', path, '''') }
			sudo: true
			onLines: nil
			onRun: [ :process |
				| counter stdin |
				
				stdin := process stdinStream.
				
				stdin
					nextPutAll: fileContent;
					flush.
				
				endsWithLf ifFalse: [
					stdin lf
				].
	
				stdin
					end;
					end; "strange: second time, because pty only transforms it to EOF if on a empty line, else it is just an end of line"
					flush.

				"Go sure that the pipe ends. Send additional endings if stalled"
				counter := 0.
				[
					(Delay forMilliseconds: 100) wait.
					counter := counter + 1.
					process isComplete not and: [ counter <= 10 ]
				] whileTrue: [
					"OPTIMIZE Strangely we need this on real Ubuntu. WTF?!"
					Transcript crShow: 'end/flush stream ...'.
					stdin
						end;
						flush.
				]

			]
			onFinish: nil.

		aModeString ifNotBlank: [
			self
				runSshOSSUnixSubprocess: 'chmod'
				args: { 
						aModeString.
						path }
				sudo: true
				onLines: nil
				onRun: nil
				onFinish: nil ].
		
		anOwnerString ifNotBlank: [
			self
				runSshOSSUnixSubprocess: 'chown'
				args: { (anOwnerString, ':', aGroupString). path }
				sudo: true
				onLines: nil
				onRun: nil
				onFinish: nil ].
			
		aBlock value.
	]
]

{ #category : #shell }
GSCCore >> sudoAsyncWriteFile: aFilePath with: aString then: aBlock [

	self sudoAsyncWriteFile: aFilePath owner: nil group: nil mode: nil with: aString then: aBlock

]

{ #category : #shell }
GSCCore >> sudoEnsureDirectory: aDirPath owner: anOwnerString group: aGroupString mode: aModeString [
	self sudoEnsureDirectory: aDirPath owner: anOwnerString group: aGroupString mode: aModeString then: nil
]

{ #category : #shell }
GSCCore >> sudoEnsureDirectory: aDirPath owner: anOwnerString group: aGroupString mode: aModeString then: aBlock [

	| path |

	path := aDirPath asPath pathString.
	
	self forkShellBlock: [
		"Ging nicht mit tee, weil es nicht exit gemacht hat"
		self
			runSshOSSUnixSubprocess: 'mkdir'
			args: { '-p'. path }
			sudo: true
			onLines: nil
			onRun: nil
			onFinish: nil.

		aModeString ifNotBlank: [
			self
				runSshOSSUnixSubprocess: 'chmod'
				args: { 
						aModeString.
						path }
				sudo: true
				onLines: nil
				onRun: nil
				onFinish: nil ].
		
		anOwnerString ifNotBlank: [
			self
				runSshOSSUnixSubprocess: 'chown'
				args: { (anOwnerString, ':', aGroupString). path }
				sudo: true
				onLines: nil
				onRun: nil
				onFinish: nil ].
			
		aBlock ifNotNil: [ aBlock value ]
			
	]
]

{ #category : #'as yet unclassified' }
GSCCore >> sudoReadCommand: aCommand [
	^ self sudoReadCommand: aCommand args: #()
]

{ #category : #shell }
GSCCore >> sudoReadCommand: aCommand args: aCollection [
	^ self readCommand: aCommand sudo: true args: aCollection
]

{ #category : #shell }
GSCCore >> sudoReadFile: aFilePath [
	| path |
	path := aFilePath asPath.

	^ self sudoReadCommand: 'cat' args: { path pathString }
]

{ #category : #shell }
GSCCore >> sudoWriteFile: aFilePath owner: anOwnerString group: aGroupString mode: aModeString with: aString [

	"	self runSudoOSSUnixSubprocess: 'touch """"', aFilePath, '""""' onRun: [ :process |
		process stdinStream
			nextPutAll: aString;
			close
	] onFinish: nil."


	| path |

	self deprecated: 'use async version'.

	path := aFilePath asPath pathString.

	"Ging nicht mit tee, weil es nicht exit gemacht hat"
"		runSshOSSUnixSubprocess: 'sed'
		args: { '-n'. ('''w ', path, '''') }"

	self
		runSshOSSUnixSubprocess: 'tee'
		args: { path }
		sudo: true
		onLines: nil
		onRun: [ :process | 
			process stdinStream
				nextPutAll: aString;
				end;
				flush.]
		onFinish: nil.

	aModeString ifNotBlank: [
		self
			runSshOSSUnixSubprocess: 'chmod'
			args: { 
					aModeString.
					path }
			sudo: true
			onLines: nil
			onRun: nil
			onFinish: nil ].
	
	anOwnerString ifNotBlank: [
		self
			runSshOSSUnixSubprocess: 'chown'
			args: { (anOwnerString, ':', aGroupString). path }
			sudo: true
			onLines: nil
			onRun: nil
			onFinish: nil ]
]

{ #category : #helpers }
GSCCore >> temporaryFolder [
	^ '/tmp' asPath
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
GSCCore >> writeToShellProcess: anObject [
	shellSubprocess stdinStream
		<< anObject;
		flush
]
