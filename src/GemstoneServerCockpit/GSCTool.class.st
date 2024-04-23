Class {
	#name : #GSCTool,
	#superclass : #Object,
	#instVars : [
		'children',
		'parent',
		'log',
		'needsAttention',
		'facts',
		'errorMessage'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #adding }
GSCTool >> add: aToolClass [
	^ self add: aToolClass then: nil
]

{ #category : #adding }
GSCTool >> add: aToolClass then: aBlock [
	| child |
	
	child := aToolClass new.
	self addTool: child.

	child gatherFacts.

	aBlock ifNotNil: [
		aBlock value: child ].

"	aBlock value: (self add: aToolClass)."
	
	"At last, build it"
	child build.
	
	^ child
]

{ #category : #adding }
GSCTool >> addTool: aTool [
	aTool parent: self.
	children add: aTool.
"	aTool build."
	
	^ aTool
]

{ #category : #accessing }
GSCTool >> ancestors [
	| collection |
	collection := OrderedCollection new.
	self ancestorsDo: [ :each | collection add: each ].
	
	^ collection
]

{ #category : #accessing }
GSCTool >> ancestorsDetect: aBlock [
	self ancestorsDo: [ :each | 
		(aBlock value: each) ifTrue: [ ^ each ]
	].
	
	^ nil
]

{ #category : #'as yet unclassified' }
GSCTool >> ancestorsDetectKindOf: aClass [
	^ self ancestorsDetect: [ :each | each isKindOf: aClass ]
]

{ #category : #enumerating }
GSCTool >> ancestorsDo: aBlock [
	parent ifNotNil: [ 
		aBlock value: parent.
		parent ancestorsDo: aBlock
	]
]

{ #category : #'as yet unclassified' }
GSCTool >> appFindTool: aClass [
	^ self application descendantsDetectKindOf: aClass
]

{ #category : #'config-access' }
GSCTool >> appIndex [
	^ self application appIndex
]

{ #category : #'config-access' }
GSCTool >> appName [
	^ self application longName
]

{ #category : #'config-access' }
GSCTool >> appShortCode [
	^ self application shortCode
]

{ #category : #accessing }
GSCTool >> application [
	"Works only if the caller is inside an application tree, but not on a top level branch"
	| app |
	app := self ancestors atLast: 2 ifAbsent: [ ^ nil ].
	
	(app isKindOf: GSCApplication) ifFalse: [ ^ nil ].
	
	^ app
]

{ #category : #'as yet unclassified' }
GSCTool >> beNeedsAttention [
	needsAttention := true
]

{ #category : #'as yet unclassified' }
GSCTool >> beNeedsAttention: aLogString [
	self log: aLogString.
	self beNeedsAttention

]

{ #category : #'as yet unclassified' }
GSCTool >> beNotNeedsAttention [
	needsAttention := false
]

{ #category : #building }
GSCTool >> build [
	"subclasses"
]

{ #category : #checking }
GSCTool >> check [

	needsAttention := false.
	self checkMe.

	self checkChildren.
	
]

{ #category : #initialization }
GSCTool >> checkChildren [
	self children do: [ :each | each check ]
]

{ #category : #'as yet unclassified' }
GSCTool >> checkMe [
	"subclasses"
]

{ #category : #'as yet unclassified' }
GSCTool >> childNeedsAttention [
	^ self children anySatisfy: [ :each | each needsAttention ]
]

{ #category : #accessing }
GSCTool >> children [

	^ children
]

{ #category : #'as yet unclassified' }
GSCTool >> clearError [
	errorMessage := nil
]

{ #category : #logging }
GSCTool >> clearFacts [
	facts := Dictionary new
]

{ #category : #logging }
GSCTool >> clearLog [
	log := OrderedCollection new
]

{ #category : #accessing }
GSCTool >> config [
	^ self scheme config
]

{ #category : #accessing }
GSCTool >> configAt: aConfigKey [
	| value |
	value := self config at: aConfigKey.
	
	value ifNil: [
		self isRoot ifFalse: [
			value := self root config at: aConfigKey ]].
	
	^ value
]

{ #category : #accessing }
GSCTool >> configAt: aConfigKey default: aBlock [
	^ (self configAt: aConfigKey) ifNil: [
		(self configAt: aConfigKey put: aBlock value)
	]
]

{ #category : #accessing }
GSCTool >> configAt: aConfigKey ifBlank: aBlock [
	^ (self configAt: aConfigKey) ifBlank: aBlock
]

{ #category : #accessing }
GSCTool >> configAt: aConfigKey put: aValue [
	| c value |
	c := self config.
	value := c at: aConfigKey put: aValue.
	
	"We always savely store changes to disk"
	c storeToFile.
	
	^ value
]

{ #category : #'as yet unclassified' }
GSCTool >> core [
	^ GSCCore instance
]

{ #category : #'as yet unclassified' }
GSCTool >> descendantNeedsAttention [
	self descendantsDo: [ :each | each needsAttention ifTrue: [ ^ true ] ].
	
	^ false
]

{ #category : #enumerating }
GSCTool >> descendantsCollect: aBlock [
	| collection |
	collection := OrderedCollection new.
	self descendantsDo: [ :each | collection add: (aBlock value: each) ].
	^ collection
]

{ #category : #enumerating }
GSCTool >> descendantsDetect: aBlock [
	self descendantsDo: [ :each | (aBlock value: each) ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : #enumerating }
GSCTool >> descendantsDetectKindOf: aClass [
	^ self descendantsDetect: [ :each | each isKindOf: aClass ]
]

{ #category : #enumerating }
GSCTool >> descendantsDo: aBlock [
	children do: [ :each |
		aBlock value: each.
		each descendantsDo: aBlock ]
]

{ #category : #enumerating }
GSCTool >> descendantsSelect: aBlock [
	| collection |
	collection := OrderedCollection new.
	self descendantsDo: [ :each | (aBlock value: each) ifTrue: [ collection add: each ] ].
	^ collection
]

{ #category : #'as yet unclassified' }
GSCTool >> doCheck [
	self core doInBackground: [
		self check ]
]

{ #category : #'as yet unclassified' }
GSCTool >> doCheckMe [
	self checkMe
]

{ #category : #'as yet unclassified' }
GSCTool >> doClearLog [
	self clearLog
]

{ #category : #accessing }
GSCTool >> errorMessage [
	^ errorMessage
]

{ #category : #accessing }
GSCTool >> errorMessage: aString [
	errorMessage := aString
]

{ #category : #accessing }
GSCTool >> factAt: aName [
	^ facts at: aName ifAbsent: [ self errorMessage: 'Unknown fact'. nil ]
]

{ #category : #accessing }
GSCTool >> factAt: aName put: aValue [
	facts at: aName put: aValue
]

{ #category : #'as yet unclassified' }
GSCTool >> gatherFacts [
	"subclasses"
]

{ #category : #'config-access' }
GSCTool >> gemstoneGsHome [
	^ self root gemstoneGsHome
]

{ #category : #testing }
GSCTool >> hasChildren [
	^ children notBlank
]

{ #category : #initialization }
GSCTool >> init [
	self initMe.
	self initChildren.
]

{ #category : #initialization }
GSCTool >> initChildren [
	self children do: [ :each | each init ]
]

{ #category : #initialization }
GSCTool >> initMe [
	"subclasses"
]

{ #category : #initialization }
GSCTool >> initialize [
	super initialize.
	
	children := OrderedCollection new.
	self clearLog.
	self clearFacts.
	
	needsAttention := false
]

{ #category : #testing }
GSCTool >> isInApplication [
	"Answers if the current tool is inside an application tree branch, or outside"
	^ self application notNil
]

{ #category : #testing }
GSCTool >> isRoot [
	^ false
]

{ #category : #accessing }
GSCTool >> log: aMessage [
	log add: aMessage
]

{ #category : #'as yet unclassified' }
GSCTool >> logTail [
	^ log copyWithoutBlanks lastAtMost: 10
]

{ #category : #testing }
GSCTool >> needsAttention [
	^ needsAttention
]

{ #category : #accessing }
GSCTool >> parent [

	^ parent
]

{ #category : #accessing }
GSCTool >> parent: anObject [

	parent := anObject
]

{ #category : #'as yet unclassified' }
GSCTool >> performToolAction: aSelector [
	^ [
		self clearError.
		[ self perform: aSelector ] on: GSCMissingSudoPassword do: [ :e |
			self errorMessage: 'This tool needs the sudo password'.
			"TODO: Request password on the fly? But how? This is not a UI component"
"			e resume."
		]
		
	] on: Error do: [ :e |
		self log: ('ERROR ', e asString).
		self core isDevelopment ifTrue: [ e pass ]
	]
]

{ #category : #accessing }
GSCTool >> refresh [
	self initMe.
	self checkMe.
]

{ #category : #adding }
GSCTool >> removeTool: aTool [

	aTool parent: nil.

	children remove: aTool.
	
	^ aTool
]

{ #category : #rendering }
GSCTool >> renderActionsOn: html [
	html div: [
		self toolActionSelectors do: [ :each |
			html anchorButton
				callback: [ self performToolAction: each ];
				with: [
					html text: (each allButFirst: 2)].
		
	] ]
]

{ #category : #rendering }
GSCTool >> renderBodyOn: html [
	"subclasses"
]

{ #category : #rendering }
GSCTool >> renderFactsOn: html [
	facts ifNotBlank: [
		facts keysAndValuesDo: [ :key :value |
			self renderLabel: key text: value on: html.
"			html table: [ 
				html tableRow: [ 
					html tableHeading: key.
					html tableData: value ] ]" ] ]
]

{ #category : #rendering }
GSCTool >> renderLabel: aString number: aNumber on: html [

	html div class: 'labelAndValue'; with: [
		html label: aString.
		html text: ': '.
		html span: aNumber printString ]
]

{ #category : #rendering }
GSCTool >> renderLabel: aString text: aString2 on: html [

	html div class: 'labelAndValue'; with: [
		html label: aString.
		html text: ': '.
		html span: aString2 ]
]

{ #category : #rendering }
GSCTool >> renderListEntryOn: html [
	self needsAttention ifTrue: [
		html span: '! '
	].

	html span: self title.
	html span class: 'attributes'; with: [
	
		self hasChildren ifTrue: [
			self descendantNeedsAttention
				ifTrue: [ html span: '! >' ]
				ifFalse: [ html span: '>' ] ] ]
]

{ #category : #rendering }
GSCTool >> renderListHeadEntryOn: html [

	"In a pane, render myself again on top of the children list, for UX convenience.
	But without the children icon"
	self needsAttention ifTrue: [
		html span: '! '
	].

	html span: '< Main'.
]

{ #category : #rendering }
GSCTool >> renderLogOn: html [
	log ifNotEmpty: [ 
		html div class: 'log'; with: [
			html heading: 'Logtail'.
			html preformatted: [
				self logTail do: [ :each |
					html text: each.
					html text: String lf
				] ] ].
		
		html anchor
			callback: [ self showFullLog ];
			with: 'Show full ...'
	]
]

{ #category : #rendering }
GSCTool >> renderOn: html [
	html heading: self title.

	errorMessage ifNotBlank: [ html div class: 'error'; with: errorMessage ].

	self needsAttention ifTrue: [ html div class: 'needsAttention'; with: 'Needs attention!' ].

	self renderActionsOn: html.
	self renderFactsOn: html.

	[
		self renderBodyOn: html.
	] on: GSCMissingSudoPassword do: [ :e |
		html div class: 'error'; with: 'This tool needs the sudo password'
	].

	self renderLogOn: html.
]

{ #category : #accessing }
GSCTool >> root [
	^ self ancestors last
]

{ #category : #'as yet unclassified' }
GSCTool >> rootFindTool: aClass [
	^ self root descendantsDetectKindOf: aClass
]

{ #category : #'as yet unclassified' }
GSCTool >> rootFindTools: aClass [
	^ self root descendantsSelect: [ :each | each isKindOf: aClass ]
]

{ #category : #'as yet unclassified' }
GSCTool >> runAndPrintSmalltalk: aString stone: aStoneName [
	| smalltalkCode bash |

	smalltalkCode := aString trimBoth.
	
	"Ensure Smalltalk code ends with a dot"
"	(smalltalkCode last = $.) ifFalse: [
		smalltalkCode := smalltalkCode, '.'.
	]."

	bash := 'startTopaz ', aStoneName, ' -q -l << EOF >& /tmp/gscTopaz.log
iferror stack
display oops
login
run
(GsFile openWrite: ''/tmp/gscSmalltalkOutput.log'') nextPutAllUtf8: ([ ', smalltalkCode, ' ] value asString); close
%
commit
logout
exit
EOF
cat /tmp/gscSmalltalkOutput.log
'.

	^ self runBashScript: bash.
]

{ #category : #'as yet unclassified' }
GSCTool >> runBashScript: aString [
	| lines |

	self log: 'Bash script: ', aString.

	lines := OrderedCollection new.

	"We need to pipe stdin via tee so that bash does not invoke interactive"
	self core
		runShell: 'tee | bash --login'
		args: {  }
		stdin: aString
		sudo: false
		onOutput: [ :newLines | lines addAll: newLines ]
		onRun: nil
		onFinish: nil.

	^ lines joinUsingLf

]

{ #category : #'as yet unclassified' }
GSCTool >> runShellCommand: aString [
	self runShellCommand: aString then: nil
]

{ #category : #'as yet unclassified' }
GSCTool >> runShellCommand: aString then: aBlock [
	self log: 'Shell command: ', aString.
	
	self core runAsyncShell: aString onOutput: [ :lines |
		"log addAll: lines" ] onFinish: [ :success |
"			self refresh."
			aBlock ifNotNil: [
				success ifTrue: aBlock ]	
	]
]

{ #category : #'as yet unclassified' }
GSCTool >> runSmalltalk: aString stone: aStoneName [
	| smalltalkCode bash |

	smalltalkCode := aString trimBoth.
	
	"Ensure Smalltalk code ends with a dot"
"	(smalltalkCode last = $.) ifFalse: [
		smalltalkCode := smalltalkCode, '.'.
	]."

	bash := 'startTopaz ', aStoneName, ' -q -l << EOF >& /tmp/gscTopaz.log
iferror stack
display oops
login
run
', smalltalkCode, '
%
commit
logout
exit
EOF
'.

	^ self runBashScript: bash.
]

{ #category : #'as yet unclassified' }
GSCTool >> runSudoShellCommand: aString [
	self runSudoShellCommand: aString then: nil
]

{ #category : #'as yet unclassified' }
GSCTool >> runSudoShellCommand: aString then: aBlock [
	self log: 'Shell sudo command: ', aString.

	self core runSudoAsyncShell: aString onOutput: [ :lines |
		"log addAll: lines" ] onFinish: [ :success |
"			self refresh."
			aBlock ifNotNil: [
				success ifTrue: aBlock ]
	]
]

{ #category : #'as yet unclassified' }
GSCTool >> runTodeCommand: aCommand stone: aStoneName [
	self runShellCommand: 'todeIt ', aStoneName, ' ', aCommand
]

{ #category : #'as yet unclassified' }
GSCTool >> runTopaz: aString stone: aStoneName [
	| bash |

	bash := 'startTopaz ', aStoneName, ' -q -l << EOF >& /tmp/gscTopaz.log
', aString, '
EOF
'.

	^ self runBashScript: bash.
]

{ #category : #accessing }
GSCTool >> scheme [
	^ self application ifNil: [ self root scheme ] ifNotNil: [ :app |
		app scheme ]
]

{ #category : #'as yet unclassified' }
GSCTool >> serverAdminEmail [
	^ self root configAt: 'server:adminEmail'
]

{ #category : #'config-access' }
GSCTool >> serverGroupname [
	^ self serverUsername
]

{ #category : #'config-access' }
GSCTool >> serverUserHome [
	^ self root userHome
]

{ #category : #'config-access' }
GSCTool >> serverUsername [
	^ self root configAt: 'server:username'
]

{ #category : #'as yet unclassified' }
GSCTool >> showFullLog [
	self uiViewText: log joinUsingLf
]

{ #category : #accessing }
GSCTool >> title [
	^ self className
]

{ #category : #'as yet unclassified' }
GSCTool >> toolActionSelectors [
	| selectors |
	selectors := (self class allSelectorsBelow: GSCTool superclass) select: [:each |
		(each beginsWith: 'do') and: [ (each at: 3) isUppercase]].
	^ selectors sorted
]

{ #category : #'as yet unclassified' }
GSCTool >> ui [
	| mainComponent |
	mainComponent := (WACurrentRequestContext value) session presenter.
	
	^ mainComponent
]

{ #category : #'as yet unclassified' }
GSCTool >> uiEditText: aString then: aBlock [
	self ui editText: aString then: aBlock
]

{ #category : #'as yet unclassified' }
GSCTool >> uiShowFullscreen: aRenderable [
	self ui showFullscreen: aRenderable
]

{ #category : #'as yet unclassified' }
GSCTool >> uiTailFile: aFilePath [
	| content |
	content := self core sudoTailFile: aFilePath lines: 100.

	self uiViewText: content

]

{ #category : #'as yet unclassified' }
GSCTool >> uiViewFile: aFilePath [
	| content |
	content := self core sudoReadFile: aFilePath.

	self uiViewText: content

]

{ #category : #'as yet unclassified' }
GSCTool >> uiViewText: aString [
	^ self uiViewText: aString then: [  ]
]

{ #category : #'as yet unclassified' }
GSCTool >> uiViewText: aString then: aBlock [
	self ui viewText: aString then: aBlock
]
