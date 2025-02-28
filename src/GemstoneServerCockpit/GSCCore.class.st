Class {
	#name : 'GSCCore',
	#superclass : 'Object',
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
		'subprocessCommandLabel',
		'hasPasswordlessSudo',
		'gscInstallDir'
	],
	#classVars : [
		'AccentNormalizationMap',
		'Instance'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'as yet unclassified' }
GSCCore class >> enableAutomation [
	Smalltalk addToStartUpList: self.
"	Smalltalk addToShutDownList: self"
]

{ #category : 'initialization' }
GSCCore class >> initialize [
	super initialize.
	self enableAutomation
]

{ #category : 'actions' }
GSCCore class >> install [
	self instance install
]

{ #category : 'accessing' }
GSCCore class >> instance [
	Instance ifNil: [ Instance := self new ].
	^ Instance
]

{ #category : 'system startup' }
GSCCore class >> startUp: isComingUp [
	isComingUp ifTrue: [
		"Automatic read in the config files on the server"
		[ self instance startUp ] on: Error do: [ "hm, what?" ]
	]
]

{ #category : 'actions' }
GSCCore class >> update [
	self instance update
]

{ #category : 'shell' }
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

{ #category : 'config' }
GSCCore >> applicationUrl [
	^ self seasideApplication url
]

{ #category : 'sudo' }
GSCCore >> autoexpireSudoPassword [

	(sudoPasswortTimestamp isNil or: [ sudoPasswortTimestamp < (DateAndTime now - 2 hours)]) ifTrue: [ 
		temporarySudoPassword := nil ]
]

{ #category : 'accessing' }
GSCCore >> beDevelopment [
	isDevelopment := true
]

{ #category : 'accessing' }
GSCCore >> beNotDevelopment [
	isDevelopment := false
]

{ #category : 'sudo' }
GSCCore >> checkPermissions [
	| output |
	output := self readCommand: 'sudo --non-interactive echo -n "yes"'.
	
	hasPasswordlessSudo := (output = 'yes')

]

{ #category : 'accessing' }
GSCCore >> clearSubprocessTailLines [
	subprocessTailLines := OrderedCollection new
]

{ #category : 'sudo' }
GSCCore >> clearSudoPassword [
	temporarySudoPassword := nil
]

{ #category : 'shell' }
GSCCore >> createOSSUnixSubprocess [
	| process gsHome path |
	
"	gsHome := rootTool ifNotNil: [ rootTool gemstoneGsHome pathString ].
	path := Smalltalk os environment at: 'PATH'."
	
	process := OSSUnixSubprocess new.
	
"	gsHome ifNotBlank: [
		process
			environmentAt: 'GS_HOME' put: gsHome;
			environmentAt: 'PATH' put: (gsHome, '/bin:', path) ]."
	
	^ process
]

{ #category : 'shell' }
GSCCore >> dirExists: aPathString [
	^ self runSudoShellIsSuccess: ('test -d "', (aPathString asPath pathString), '"')
]

{ #category : 'shell' }
GSCCore >> doInBackground: aBlock [

"	self isShellProcessRunning ifTrue: [ 
		self error: 'Another shell process is running'. ^ self ]."
	| name |
	name := 'GSC shell process'.

	Processor activeProcess name = name ifTrue: [
		aBlock value
	] ifFalse: [

		self clearSubprocessTailLines.
		aBlock
			forkAt: Processor userInterruptPriority
			named: name
	]
]

{ #category : 'shell' }
GSCCore >> ensureRunningSshControlMaster [
	| process |

	process := OSSUnixSubprocess new.
	
	process
		command: 'ssh';
		arguments: { '-q'. '-S'. '/tmp/gscControlMaster.sock'. '-O'. 'check'. 'nonrelevanthost' };
		runAndWait.
		
	process isSuccess ifFalse: [

		OSSUnixSubprocess new
			command: 'ssh';
			arguments: { '-fN'. '-oControlMaster=yes'. '-oControlPersist=yes'. '-oControlPath=/tmp/gscControlMaster.sock'. 'localhost' };
			runAndWait.
	]
]

{ #category : 'actions' }
GSCCore >> ensureWebserver [
	"Webserver starten"
	| webserver |
	webserver := GSCZincServerAdaptor default.
	(webserver isNil or: [ webserver isRunning not ]) ifTrue: [
		self startWebserver ]
]

{ #category : 'config' }
GSCCore >> fileDepotDir [
	^ self gscInstallDir / 'pharo-local' / 'iceberg' / 'talk-small-be-open' / 'gemstone-server-cockpit' / 'depot'
]

{ #category : 'config' }
GSCCore >> fileDepotScriptsDir [
	^ self fileDepotDir / 'shell-scripts'
]

{ #category : 'shell' }
GSCCore >> fileExists: aPathString [
	^ self runSudoShellIsSuccess: ('test -f "', (aPathString asPath pathString), '"')
]

{ #category : 'helpers' }
GSCCore >> filenameFor: aString [
	| map sanitized |
	"Konvertiert einen String in einen String passend für Filenamen
	
	IMPORTANT: Intended for download filenames. For real storing of files on the server use the stricter serverFilenameFor: 
	"
	
	map := {
		$* asInteger -> $_ asInteger.
		$/ asInteger -> $_ asInteger.
		$, asInteger -> $_ asInteger.
		Character space asInteger -> $_ asInteger. 
	} asDictionary.
	
	sanitized := aString copyWithout: $".
	
	^ (self translateString: sanitized map: map) asFileName "asDromedaryCase"
]

{ #category : 'accessing' }
GSCCore >> filesystemRoot [

	^ filesystemRoot
]

{ #category : 'accessing' }
GSCCore >> filesystemRoot: aString [
	filesystemRoot := aString asPath.
	
	filesystemRoot isRoot ifFalse: [
		self sudoEnsureDirectory: filesystemRoot owner: self serverUsername group: self serverUsername mode: 'u=rwx,g=rwx,o=rx'
	]
]

{ #category : 'sudo' }
GSCCore >> getSudoPassword [
	
	self autoexpireSudoPassword.
	
	temporarySudoPassword ifNil: [ GSCMissingSudoPassword signal: 'You need to give the sudo password' ].
	
	"prolong, when in use"
	self timestampSudoPassword.
	
	^ temporarySudoPassword
]

{ #category : 'config' }
GSCCore >> gscInstallDir [
	^ gscInstallDir
]

{ #category : 'accessing' }
GSCCore >> hasPasswordlessSudo [
	^ hasPasswordlessSudo = true
]

{ #category : 'initialization' }
GSCCore >> initialize [
	super initialize.

	isDevelopment := false.
	filesystemRoot := Path root.
]

{ #category : 'initialization' }
GSCCore >> initializeAccentNormalizationMap [
	| sourceChars targetChars |

	sourceChars := #(193 225 192 224 194 226 461 462 258 259 195 227 7842 7843 7840 7841 196 228 197 229 256 257 260 261 7844 7845 7846 7847 7850 7851 7848 7849 7852 7853 7854 7855 7856 7857 7860 7861 7858 7859 7862 7863 506 507 262 263 264 265 268 269 266 267 199 231 270 271 272 273 201 233 200 232 202 234 282 283 276 277 7868 7869 7866 7867 278 279 203 235 274 275 280 281 7870 7871 7872 7873 7876 7877 7874 7875 7864 7865 7878 7879 286 287 284 285 288 289 290 291 292 293 294 295 205 237 204 236 300 301 206 238 463 464 207 239 296 297 302 303 298 299 7880 7881 7882 7883 308 309 310 311 313 314 317 318 315 316 321 322 319 320 323 324 327 328 209 241 325 326 211 243 210 242 334 335 212 244 7888 7889 7890 7891 7894 7895 7892 7893 465 466 214 246 336 337 213 245 216 248 510 511 332 333 7886 7887 416 417 7898 7899 7900 7901 7904 7905 7902 7903 7906 7907 7884 7885 7896 7897 7764 7765 7766 7767 340 341 344 345 342 343 346 347 348 349 352 353 350 351 356 357 354 355 358 359 218 250 217 249 364 365 219 251 467 468 366 367 220 252 471 472 475 476 473 474 469 470 368 369 360 361 370 371 362 363 7910 7911 431 432 7912 7913 7914 7915 7918 7919 7916 7917 7920 7921 7908 7909 7810 7811 7808 7809 372 373 7812 7813 221 253 7922 7923 374 375 376 255 7928 7929 7926 7927 7924 7925 377 378 381 382 379 380 208).

	targetChars := #(A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a A a C c C c C c C c C c D d D d E e E e E e E e E e E e E e E e E e E e E e E e E e E e E e E e E e G g G g G g G g H h H h I i I i I i I i I i I i I i I i I i I i I i J j K k L l L l L l L l L l N n N n N n N n O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o O o P p P p R r R r R r S s S s S s S s T t T t T t U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u U u W w W w W w W w Y y Y y Y y Y y Y y Y y Y y Z z Z z Z z D).

	AccentNormalizationMap := IdentityDictionary new. 

	sourceChars with: targetChars do: [:source :target |
		AccentNormalizationMap at: source put: target first asInteger]
]

{ #category : 'setup' }
GSCCore >> install [
	self installStarterShellScript.

	self restartWebserver.
	
	self installSeasideComponents.

	self setup.
]

{ #category : 'setup' }
GSCCore >> installSeasideComponents [
	| app appPath |

	appPath := self instanceId asString.

	app := WAAdmin 
		register: GSCMainCockpit
		asApplicationAt: appPath.

	app addLibrary: GSCWaFileLibrary.
"	app configuration addParent: WAEmailConfiguration instance."

	app exceptionHandler: WADebugErrorHandler.

"nicht, weil versteckt	WAAdmin defaultDispatcher defaultName: appPath"
]

{ #category : 'setup' }
GSCCore >> installStarterShellScript [
	| filename fileRef script |
	filename := './start-gsc.sh'.

	filename asFileReference isFile ifTrue: [
		fileRef := (filename, '.original') asFileReference ensureDelete. 
	] ifFalse: [ 
		fileRef := filename asFileReference.
	].

	script := '#!/bin/bash

NAME=$(dirname "$0")
DIR=$(realpath "$NAME")

cd $DIR

if [ "$1" = "ui" ]
then
  xpra start :100
  export DISPLAY=:100
  ./pharo-ui gsc.image >& pharo.log
else
  ./pharo gsc.image --no-quit 2>&1 | tee pharo.log
fi

'.
	
	fileRef writeStreamEncoded: 'utf-8' do: [ :s |
		s nextPutAll: script withUnixLineEndings.
	].

	fileRef permissions: (FileSystemPermission posixPermissions: 8r770)

]

{ #category : 'config' }
GSCCore >> instanceId [
	uuidString ifNil: [
		uuidString := UUID new asString36.
		
		"Logging, so we can get that ID from somewhere, if unknown"
		Transcript crShow: 'GSC application ID: '.
		Transcript show: uuidString.
		Transcript cr.
	].
	^ uuidString
]

{ #category : 'testing' }
GSCCore >> isDevelopment [
	^ isDevelopment
]

{ #category : 'testing' }
GSCCore >> isShellProcessPresent [
	^ shellSubprocess notNil
]

{ #category : 'testing' }
GSCCore >> isShellProcessRunning [
	^ shellSubprocess notNil and: [ shellSubprocess isComplete not ]
]

{ #category : 'testing' }
GSCCore >> isSudoPasswordSet [
	self autoexpireSudoPassword.
	^ temporarySudoPassword notBlank
]

{ #category : 'shell' }
GSCCore >> killShellProcess [
	"Kill the OS subprocess. The Pharo process then will terminate automatically"
	shellSubprocess ifNotNil: [
		shellSubprocess isRunning ifTrue: [ 
			shellSubprocess terminate ].
		shellSubprocess := nil.
	].
]

{ #category : 'logging' }
GSCCore >> log: aString [
	Transcript crShow: aString
]

{ #category : 'testing' }
GSCCore >> needsSudoPassword [
	^ (self isSudoPasswordSet or: [ self hasPasswordlessSudo ]) not
]

{ #category : 'helpers' }
GSCCore >> normalizeAccents: aString [
	AccentNormalizationMap ifNil: [self initializeAccentNormalizationMap].
	^self translateString: aString map: AccentNormalizationMap
]

{ #category : 'shell' }
GSCCore >> readCommand: aCommand [
	^ self readCommand: aCommand args: #()
]

{ #category : 'shell' }
GSCCore >> readCommand: aCommand args: aCollection [
	^ self readCommand: aCommand sudo: false args: aCollection
]

{ #category : 'shell' }
GSCCore >> readCommand: aCommand sudo: aBoolean args: aCollection [

	| lines |
	lines := OrderedCollection new.

	self
		runShell: aCommand
		args: aCollection
		stdin: nil
		sudo: aBoolean
		onOutput: [ :newLines | lines addAll: newLines ]
		onRun: nil
		onFinish: nil.

	^ lines joinUsingLf
]

{ #category : 'helpers' }
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

{ #category : 'actions' }
GSCCore >> restartWebserver [
	self stopWebserver.
	self startWebserver
]

{ #category : 'accessing' }
GSCCore >> rootTool [

	^ rootTool
]

{ #category : 'shell' }
GSCCore >> runAsyncShell: aString onOutput: aBlock [
	^ self runAsyncShell: aString onOutput: aBlock onFinish: nil
]

{ #category : 'shell' }
GSCCore >> runAsyncShell: aString onOutput: aBlock onFinish: aFinishBlock [
	^ self runAsyncShell: aString sudo: false onOutput: aBlock onFinish: aFinishBlock
]

{ #category : 'shell' }
GSCCore >> runAsyncShell: aString sudo: aSudoBoolean onOutput: aBlock onFinish: aFinishBlock [

	self doInBackground: [
		self
			runShell: aString
			args: {  }
			stdin: nil
			sudo: aSudoBoolean
			onOutput: aBlock
			onRun: nil
			onFinish: aFinishBlock
	]
]

{ #category : 'shell' }
GSCCore >> runShell: aCommandString args: anArgsCollection stdin: aStdinString sudo: aSudoBoolean onOutput: aLinesBlock onRun: aRunBlock onFinish: aFinishBlock [

	^ self runShell: aCommandString args: anArgsCollection tty: false stdin: aStdinString sudo: aSudoBoolean onOutput: aLinesBlock onRun: aRunBlock onFinish: aFinishBlock
]

{ #category : 'shell' }
GSCCore >> runShell: aCommandString args: anArgsCollection sudo: aSudoBoolean [

	^ self runShell: aCommandString args: anArgsCollection stdin: nil sudo: aSudoBoolean onOutput: nil onRun: nil onFinish: nil
]

{ #category : 'shell' }
GSCCore >> runShell: aCommandString args: anArgsCollection tty: aTtyBoolean stdin: aStdinString sudo: aSudoBoolean onOutput: aLinesBlock onRun: aRunBlock onFinish: aFinishBlock [

	| process cmd args envVars lineReader catchFirstSudoPrompt runBlockDone fireRunBlock linesBlock needSudoPassword |

"Best info for ssh/tty/stdin etc.
https://superuser.com/questions/1015988/process-running-in-ssh-allocated-tty-not-terminating-once-stdin-is-consumed
"

	needSudoPassword := aSudoBoolean and: [ self hasPasswordlessSudo not ].
	
	self isShellProcessRunning ifTrue: [ self error: 'Another shell process is running.' ].

	subprocessCommandLabel := aCommandString.
	
	runBlockDone := false.

	linesBlock := aLinesBlock ifNil: [ [ :lines |
			self isDevelopment ifTrue: [
				lines do: [ :each |
					Transcript crShow: each
				]
			]
		]
	].

"	subprocessTailLines := OrderedCollection new."

	fireRunBlock := [ :proc |
		"do this after the main sudo password has been streamed into the pipe. So that runBlock is ready
		for things like stdin"
		runBlockDone ifFalse: [

			"Feed stdin, if any"
			aStdinString ifNotBlank: [
				"We have to delay the input, after the stty -echo has been done"
				"Ugly, but there seems to be no real other solution"
				aTtyBoolean ifTrue: [
					(Delay forMilliseconds: 800) wait ].
				
				proc stdinStream
					nextPutAll: aStdinString withUnixLineEndings;
					flush;
					close.
			].

			"Run a code, if any"
			aRunBlock ifNotNil: [
				aRunBlock value: proc.
			].
		
			runBlockDone := true.
		].
	].

	process := self createOSSUnixSubprocess.

	envVars := Dictionary new.

	"Some applications like 'service' have complained about non-capable terminal. We explicitely set to dumb."
	envVars at: 'TERM' put: 'dumb'. 

	rootTool ifNotNil: [
		envVars at: 'GS_HOME' put: rootTool gemstoneGsHome pathString.
		envVars at: 'PATH' put: (rootTool gemstoneGsHome pathString, '/bin:$PATH').
	].

	cmd := 'ssh'.

	args := Array streamContents: [ :a |
		a nextPut: '-q'.

		aTtyBoolean ifTrue: [
			a nextPut: '-tt'. ].

		a nextPut: '-S /tmp/gscControlMaster.sock'.
		
		a nextPut: 'localhost'.

		aTtyBoolean ifTrue: [
			"Prevent the input being echoed as output"
"			a nextPut: 'stty icanon isig iexten iutf8 -echo eof ^D intr ^C ;'."
			a nextPut: 'stty -echo icanon isig iexten iutf8 ;'. ].
		
		"Used as a container to serialize the real commands"
		a nextPut: 'env -S'.

		"Define a unique sudo prompt, for all maybe nested sudo invocations. Not for our own sudo."
		a nextPut: ('SUDO_PROMPT=', sudoPrompt).
		
		envVars keysAndValuesDo: [ :key :value |
			a nextPut: (key, '=', value).
		].

		"Invoke sudo, taking password from stdin"
		aSudoBoolean ifTrue: [
			a nextPut: 'sudo'.
			a nextPut: '--preserve-env'.
			a nextPut: '--prompt=""'.
			a nextPut: '--stdin'.
			a nextPut: '--' ].

		a nextPut: aCommandString withUnixLineEndings. "Not sure if conversion needed?"
		
		anArgsCollection ifNotBlank: [
			"Since these arguments will be sent as a string to be executed by the
			remote shell, we need to be careful with spaces."
			anArgsCollection do: [ :each |
				| sanitized |
				sanitized := '''', each, ''''.
				a nextPut: sanitized
			]
		].

	].

	self log: (cmd, ' ', (args joinUsing: String space)).
		
	shellSubprocess := process.
	
	process
		command: cmd;
		arguments: args;
		redirectStdout;
		redirectStdin;
		createMissingStandardStreams: true.

	"Optionally send some stdin text. Might not work, if with sudo"
"	aStdinString ifNotBlank: [
		process redirectStdin.
		process stdinStream
			nextPutAll: aStdinString;
			end;
			end;
			flush.
	]."

	"Start the subprocess and run the command"
	process run.
	
		
	"Sending sudo password into stdin with LF."
	needSudoPassword ifTrue: [
		process stdinStream 
			nextPutAll: (self getSudoPassword);
			nextPut: Character lf;
			flush ].

	lineReader := GSCPipeLinesReadStream new.
	
	"when sudo is involved there is a strange empty newline at the beginning"
"	needSudoPassword ifTrue: [
		lineReader ignoreLeadingNewlines: 1
	]."

	catchFirstSudoPrompt := false. "needSudoPassword."
	
	process waitForExitPollingEvery: (Delay forMilliseconds: 50) doing: [ :proc :outStream :errStream |
		
		"Read both back stdout and stderr"
		lineReader consumePipe: outStream.
		lineReader consumePipe: errStream.

		proc isComplete ifTrue: [ lineReader complete ].

		"If we do not wait for a initial sudo prompt, then we can do that immediately"
		"needSudoPassword ifFalse: ["
		fireRunBlock value: proc.
		"]."

		lineReader autoNewlineIfTimeout: 1000.

		"Always detect sudo prompt, potentially from nested sudo invocations"
		lineReader lastLine = sudoPrompt ifTrue: [
			
			proc stdinStream 
				nextPutAll: (self getSudoPassword);
				lf;
				flush.
				
			"Remove the sudo prompt"
			lineReader removeLastLine.

			(Delay forMilliseconds: 110) wait.
	
			"Detect very first initial sudo prompt, and do stuff right after that"
"			catchFirstSudoPrompt ifTrue: [ 
				catchFirstSudoPrompt := false.
				fireRunBlock value: proc
			]"

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

{ #category : 'shell' }
GSCCore >> runShellIsSuccess: aString [

	^ self
		  runShell: aString
		  args: {  }
		  sudo: false
]

{ #category : 'shell' }
GSCCore >> runSudoAsyncShell: aString onOutput: aBlock [
	^ self runSudoAsyncShell: aString onOutput: aBlock onFinish: nil
]

{ #category : 'shell' }
GSCCore >> runSudoAsyncShell: aString onOutput: aBlock onFinish: aFinishBlock [
	
	self runAsyncShell: aString sudo: true onOutput: aBlock onFinish: aFinishBlock
]

{ #category : 'shell' }
GSCCore >> runSudoShellIsSuccess: aString [

	^ self
		  runShell: aString
		  args: {  }
		  sudo: true

]

{ #category : 'helpers' }
GSCCore >> sanitizeToAscii: aString [
	| sanitized |
	sanitized := aString reject: [:c | c asciiValue > 127].
	^ sanitized
]

{ #category : 'config' }
GSCCore >> seasideApplication [
	^ WAAdmin defaultDispatcher handlerAt: self instanceId asString
]

{ #category : 'helpers' }
GSCCore >> serverFilenameFor: aString [
	"Dateinamen filtern für den Gebrauch auf dem Server. Strenges filtern."
	^(self filenameFor: (self sanitizeToAscii: (self normalizeAccents: aString))) asLowercase
]

{ #category : 'shell' }
GSCCore >> serverUsername [
	^ self rootTool configAt: 'server:username'
]

{ #category : 'sudo' }
GSCCore >> setSudoPassword: aString [
	temporarySudoPassword := aString.
	
	self timestampSudoPassword
]

{ #category : 'setup' }
GSCCore >> setup [

	"Ensure: Clear root tool first"
	rootTool := nil.

	"Do some stuff inside Pharo to set things right"
	self setupPharo.

	self setupMyself.
	
	"Build root tools"
	self setupRoot.

	"Build tools for the one or many applications, taken from their conf files"
	self setupApplicationsFromConfigFiles.
	
	"self setupExample."
	
	"Initialize the tool tree, after the instatiation of the whole tree"
	rootTool init.
"	rootTool check."

]

{ #category : 'setup' }
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

{ #category : 'setup' }
GSCCore >> setupExampleApplications [
	

	1 to: 5 do: [ :index |
		| app scheme conf |
		scheme := GSCWebApplicationSchemeV1 new.
		conf := GSCConfiguration fromFile: ('/etc/gsc/applications/', index asTwoCharacterString, '_example', index asString, '.conf').
		conf at: 'project:shortCode' put: ('ExampleApp', index asString).
		conf at: 'project:name' put: ('Example Webapp ', index asString).
		conf at: 'web:workersCount' put: index + 1.

		scheme config: conf.
		
		app := scheme buildApplicationToolInto: rootTool.
		
	]
]

{ #category : 'setup' }
GSCCore >> setupMyself [
	sudoPrompt := UUID new asString36.
	gscInstallDir := FileSystem workingDirectory asPath.

	self clearSubprocessTailLines.
	self checkPermissions.
	self ensureRunningSshControlMaster.

		
]

{ #category : 'setup' }
GSCCore >> setupPharo [
	GSCHtmlCanvas selectAsDefault
]

{ #category : 'setup' }
GSCCore >> setupRoot [
	| rootConf scheme |

"	defaultRootConf := GSCRootScheme new buildDefaultConfiguration."
	
	"Get root config from external file"
	rootConf := GSCConfiguration fromFile: ('/etc/gsc/gsc.conf').

	scheme := rootConf createSchemeDefault: GSCRootSchemeV1.

	"Store it back to the file (could have added some new default values)"
"?Why	rootConf storeToFile."
	
	"Create the root node of the tool tree"
	rootTool := scheme buildRootTool.

]

{ #category : 'setup' }
GSCCore >> startUp [
	"on Pharo start"
	
	self setup.
	
	self restartWebserver.
	
	Transcript crShow: 'GSC is running on local network only. Connect through an SSH tunnel. Example:'.
	Transcript crShow: 'ssh -t -Y -L 8888:localhost:8650 user@hostname'.
	Transcript crShow: ('Open in browser: http://localhost:8888/', self instanceId asString).
]

{ #category : 'actions' }
GSCCore >> startWebserver [
	"Start webserver, only on local network"
	GSCZincServerAdaptor startOn: self webserverPort.
]

{ #category : 'shell' }
GSCCore >> stopSshControlMaster [
	| cmd process |

	process := OSSUnixSubprocess new.
	
	cmd := 'ssh -q -S /tmp/gscControlMaster.sock -O exit localhost'.
	
	process
		command: cmd;
		runAndWait
]

{ #category : 'actions' }
GSCCore >> stopWebserver [

	| serverManager |
	
	"Make sure: Kill all"
	serverManager := WAAdmin defaultServerManager.
	serverManager adaptors do: [ :each | serverManager unregister: each ].

	ZnServer stopDefault.

	GSCZincServerAdaptor default ifNotNil: [ :server | server stop ]
]

{ #category : 'accessing' }
GSCCore >> subprocessCommandLabel [

	^ subprocessCommandLabel
]

{ #category : 'accessing' }
GSCCore >> subprocessTailLines [

	^ subprocessTailLines
]

{ #category : 'shell' }
GSCCore >> sudoAsyncWriteFile: aFilePath owner: anOwnerString group: aGroupString mode: aModeString with: aString then: aBlock [

	"	self runSudoOSSUnixSubprocess: 'touch """"', aFilePath, '""""' onRun: [ :process |
		process stdinStream
			nextPutAll: aString;
			close
	] onFinish: nil."

	self doInBackground: [
		| path fileContent |
		path := aFilePath asPath pathString.
		fileContent := aString withUnixLineEndings.

"		endsWithLf := fileContent last = Character lf."

		"Ging nicht mit tee, weil es nicht exit gemacht hat"
"nicht zuverlässig, hängt			runSshOSSUnixSubprocess: 'tee'
			args: { path }"

		"sed
		- filter out NULL chars (dont know where the hell they are appended from!)
		- write to file
		"

		self
"			runShell: 'sed'
			args: { '-n'. ('''s/\x0//g; w ', path, '''') }"
"			runShell: 'tee'
			args: { path }"
			runShell: 'dd'
			args: { 'of=',path }
			stdin: fileContent
			sudo: true
			onOutput: nil
			onRun: nil
			onFinish: nil.

		aModeString ifNotBlank: [
			self
				runShell: 'chmod'
				args: { 
						aModeString.
						path }
				sudo: true ].
		
		anOwnerString ifNotBlank: [
			| groupString |
			
			"Fallback to own users group"
			groupString := aGroupString ifBlank: [ anOwnerString ].
			
			self
				runShell: 'chown'
				args: { (anOwnerString, ':', groupString). path }
				sudo: true ].
			
		aBlock value.
	]
]

{ #category : 'shell' }
GSCCore >> sudoAsyncWriteFile: aFilePath with: aString then: aBlock [

	self sudoAsyncWriteFile: aFilePath owner: nil group: nil mode: nil with: aString then: aBlock

]

{ #category : 'shell' }
GSCCore >> sudoEnsureDirectory: aDirPath owner: anOwnerString group: aGroupString mode: aModeString [
	self sudoEnsureDirectory: aDirPath owner: anOwnerString group: aGroupString mode: aModeString then: nil
]

{ #category : 'shell' }
GSCCore >> sudoEnsureDirectory: aDirPath owner: anOwnerString group: aGroupString mode: aModeString then: aBlock [

	| path |

	path := aDirPath asPath pathString.
	
	self doInBackground: [
		self
			runShell: 'mkdir'
			args: { '-p'. path }
			sudo: true.

		aModeString ifNotBlank: [
			self
				runShell: 'chmod'
				args: { 
						aModeString.
						path }
				sudo: true ].
		
		anOwnerString ifNotBlank: [
			self
				runShell: 'chown'
				args: { (anOwnerString, ':', aGroupString). path }
				sudo: true ].
			
		aBlock ifNotNil: [ aBlock value ]
			
	]
]

{ #category : 'shell' }
GSCCore >> sudoReadCommand: aCommand [
	^ self sudoReadCommand: aCommand args: #()
]

{ #category : 'shell' }
GSCCore >> sudoReadCommand: aCommand args: aCollection [
	^ self readCommand: aCommand sudo: true args: aCollection
]

{ #category : 'shell' }
GSCCore >> sudoReadFile: aFilePath [
	| path |
	path := aFilePath asPath.

	^ self sudoReadCommand: 'cat' args: { path pathString }
]

{ #category : 'shell' }
GSCCore >> sudoTailFile: aFilePath lines: aNumber [
	| path |
	path := aFilePath asPath.

	^ self sudoReadCommand: 'tail' args: { '-n'. aNumber asString. path pathString }
]

{ #category : 'shell' }
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

{ #category : 'helpers' }
GSCCore >> temporaryFolder [
	^ '/tmp' asPath
]

{ #category : 'helpers' }
GSCCore >> temporaryUniqueFile: anExtensionString [
	| uuid file |
	uuid := UUID new.
	
	file := self temporaryFolder / (uuid greaseString, '.', anExtensionString).
	
	^ file
]

{ #category : 'sudo' }
GSCCore >> timestampSudoPassword [
	sudoPasswortTimestamp := DateAndTime now
]

{ #category : 'helpers' }
GSCCore >> translateString: aString map: aDictionary [
	| translated |
	translated := aString copy.
	translated withIndexDo: [:char :index |
		aDictionary at: char asInteger ifPresent: [:normalizedInteger |
			translated at: index put: normalizedInteger asCharacter]].
	
	^translated
]

{ #category : 'actions' }
GSCCore >> update [
	"TODO: Update git repository and load that code, but how?!"
	Metacello registry
		baseline: 'GemstoneServerCockpit';
		load
]

{ #category : 'config' }
GSCCore >> webserverPort [
	^ 8650 "Looks like: 8GSC"
]

{ #category : 'shell' }
GSCCore >> writeLineToShellProcess: aString [
	shellSubprocess stdinStream
		nextPutAll: aString;
"		cr;"
		nextPut: Character lf;
		flush
]

{ #category : 'shell' }
GSCCore >> writeToShellProcess: anObject [
	shellSubprocess stdinStream
		<< anObject;
		flush
]
