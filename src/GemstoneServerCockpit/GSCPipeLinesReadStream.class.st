Class {
	#name : 'GSCPipeLinesReadStream',
	#superclass : 'Object',
	#instVars : [
		'lines',
		'currentLineBuffer',
		'cr',
		'lf',
		'currentCharacter',
		'lastCharAt',
		'ignoreLeadingLinesCounter'
	],
	#category : 'GemstoneServerCockpit-Misc',
	#package : 'GemstoneServerCockpit',
	#tag : 'Misc'
}

{ #category : 'as yet unclassified' }
GSCPipeLinesReadStream >> autoNewlineIfTimeout: aMsInteger [
	self hasBuffered ifTrue: [
		(Time millisecondClockValue - lastCharAt) > aMsInteger ifTrue: [
			self lineComplete
	] ]
]

{ #category : 'clearing' }
GSCPipeLinesReadStream >> clearBuffer [
	currentLineBuffer := nil
]

{ #category : 'as yet unclassified' }
GSCPipeLinesReadStream >> complete [
	self lineComplete.

]

{ #category : 'as yet unclassified' }
GSCPipeLinesReadStream >> consumePipe: anOssPipe [

	[
		| char |
		char := anOssPipe next.
		char ifNotNil: [
			self nextPut: char ].
		char notNil
	] whileTrue

]

{ #category : 'as yet unclassified' }
GSCPipeLinesReadStream >> currentLineBufferString [
	^ String streamContents: [ :s |
		currentLineBuffer do: [ :each |
			s nextPut: each ] ]
]

{ #category : 'testing' }
GSCPipeLinesReadStream >> hasBuffered [
	^ currentLineBuffer notNil
]

{ #category : 'as yet unclassified' }
GSCPipeLinesReadStream >> ignoreLeadingLines: anInteger [
	ignoreLeadingLinesCounter := anInteger
]

{ #category : 'initialization' }
GSCPipeLinesReadStream >> initialize [
	super initialize.
	
	self clearBuffer.
	
	cr := Character cr.
	lf := Character lf.
	lines := OrderedCollection new.
	ignoreLeadingLinesCounter := 0
]

{ #category : 'accessing' }
GSCPipeLinesReadStream >> lastLine [
	^ self hasBuffered
		ifTrue: [ self currentLineBufferString ]
		ifFalse: [
			lines ifEmpty: [ '' ] ifNotEmpty: [ lines last ]
		]
]

{ #category : 'as yet unclassified' }
GSCPipeLinesReadStream >> lineComplete [
	| line |
	
	currentLineBuffer ifNil: [ ^ self ].

	line := self currentLineBufferString.
	self clearBuffer.

	ignoreLeadingLinesCounter > 0 ifTrue: [
		ignoreLeadingLinesCounter := ignoreLeadingLinesCounter - 1.
		^ self
	].

	lines add: line.
]

{ #category : 'instance creation' }
GSCPipeLinesReadStream >> newLine [
	currentLineBuffer := OrderedCollection new

]

{ #category : 'accessing' }
GSCPipeLinesReadStream >> nextLine [
	lines ifEmpty: [ ^ nil ].
	
	^ lines removeFirst
]

{ #category : 'accessing' }
GSCPipeLinesReadStream >> nextLines [
	| all |
	
	all := lines copy.

	lines removeAll.
	
	^ all
]

{ #category : 'accessing' }
GSCPipeLinesReadStream >> nextPut: aCharacter [

	| lastCharacter |

	aCharacter ifNil: [ ^ self ].

	lastCharAt := Time millisecondClockValue.

	lastCharacter := currentCharacter.
	currentCharacter := aCharacter.

	"ignore lf after cr"
	(lastCharacter = cr and: [ aCharacter = lf ]) ifTrue: [ ^ self ].

	"At this point we ensure that we have a line"
	self hasBuffered ifFalse: [
		self newLine ].
	
	"newline if cr or lf"
	(aCharacter = cr or: [ aCharacter = lf ]) ifTrue: [ self lineComplete. self newLine. ^ self ].
		
	currentLineBuffer add: aCharacter.


]

{ #category : 'removing' }
GSCPipeLinesReadStream >> removeLastLine [
	self hasBuffered ifTrue: [ self clearBuffer ] ifFalse: [ lines removeLast ]
]
