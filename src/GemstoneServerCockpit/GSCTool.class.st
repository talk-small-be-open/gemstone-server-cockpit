Class {
	#name : #GSCTool,
	#superclass : #Object,
	#instVars : [
		'children',
		'parent',
		'log',
		'needsAttention'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #adding }
GSCTool >> add: aToolClass [
	| child |
	
	child := aToolClass new.
	self addTool: child.

	^ child
]

{ #category : #adding }
GSCTool >> add: aToolClass then: aBlock [
	aBlock value: (self add: aToolClass)
]

{ #category : #adding }
GSCTool >> addTool: aTool [
	aTool parent: self.
	children add: aTool.
	aTool build.
	
	^ aTool
]

{ #category : #accessing }
GSCTool >> ancestors [
	| collection |
	collection := OrderedCollection new.
	self ancestorsDo: [ :each | collection add: each ].
	
	^ collection
]

{ #category : #enumerating }
GSCTool >> ancestorsDo: aBlock [
	parent ifNotNil: [ 
		aBlock value: parent.
		parent ancestorsDo: aBlock
	]
]

{ #category : #'as yet unclassified' }
GSCTool >> appName [
	^ self application longName
]

{ #category : #'as yet unclassified' }
GSCTool >> appShortCode [
	^ self application shortCode
]

{ #category : #'as yet unclassified' }
GSCTool >> appShortName [
	^ self application shortName
]

{ #category : #accessing }
GSCTool >> application [
	^ self ancestors atLast: 2
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

{ #category : #logging }
GSCTool >> clearLog [
	log := OrderedCollection new
]

{ #category : #accessing }
GSCTool >> configAt: aConfigKey [
	^ self application config at: aConfigKey
]

{ #category : #accessing }
GSCTool >> configAt: aConfigKey default: aBlock [
	^ (self configAt: aConfigKey) ifNil: [
		(self configAt: aConfigKey put: aBlock value)
	]
]

{ #category : #accessing }
GSCTool >> configAt: aConfigKey put: aValue [
	^ self application config at: aConfigKey put: aValue
]

{ #category : #'as yet unclassified' }
GSCTool >> doCheckMe [
	self checkMe
]

{ #category : #'as yet unclassified' }
GSCTool >> doClearLog [
	self clearLog
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
]

{ #category : #initialization }
GSCTool >> initialize [
	super initialize.
	
	children := OrderedCollection new.
	self clearLog.
	needsAttention := false
]

{ #category : #accessing }
GSCTool >> log: aMessage [
	log add: aMessage
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
	^ self perform: aSelector
]

{ #category : #accessing }
GSCTool >> refresh [
	self initMe
]

{ #category : #rendering }
GSCTool >> renderActionsOn: html [
	self toolActionSelectors do: [ :each |
		html anchor
			class: 'toolActionButton';
			callback: [ self performToolAction: each ];
			with: each.
		html break
	
	]
]

{ #category : #rendering }
GSCTool >> renderBodyOn: html [
	"subclasses"
]

{ #category : #rendering }
GSCTool >> renderListEntryOn: html [
	html span: self title.
	self needsAttention ifTrue: [
		html span: '!!!'
	] ifFalse: [
		self childNeedsAttention ifTrue: [ html span: '???' ]
	]
]

{ #category : #rendering }
GSCTool >> renderLogOn: html [
	log ifNotEmpty: [ 
		html heading: 'Log'.
		log do: [ :each |
			html div: each ]
	]
]

{ #category : #rendering }
GSCTool >> renderOn: html [
	html heading: self title.

	self needsAttention ifTrue: [ html div: 'ATTENTION!!!' ].
	self renderActionsOn: html.
	self renderLogOn: html.
	self renderBodyOn: html.
]

{ #category : #'as yet unclassified' }
GSCTool >> runShellCommand: aString [
	GSCCore instance runAsyncShell: aString logInto: log
]

{ #category : #accessing }
GSCTool >> title [
	^ self className
]

{ #category : #'as yet unclassified' }
GSCTool >> toolActionSelectors [
	^(self class allSelectorsBelow: GSCTool superclass) select: [:each | (each beginsWith: 'do') and: [ (each at: 3) isUppercase]]
]
