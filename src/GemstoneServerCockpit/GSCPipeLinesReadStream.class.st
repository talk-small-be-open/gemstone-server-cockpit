Class {
	#name : #GSCPipeLinesReadStream,
	#superclass : #Object,
	#instVars : [
		'lines',
		'currentLineBuffer',
		'lastCharacter',
		'cr',
		'lf'
	],
	#category : #'GemstoneServerCockpit-Misc'
}

{ #category : #clearing }
GSCPipeLinesReadStream >> clearBuffer [
	currentLineBuffer := nil
]

{ #category : #'as yet unclassified' }
GSCPipeLinesReadStream >> complete [
	self lineComplete
]

{ #category : #'as yet unclassified' }
GSCPipeLinesReadStream >> consumePipe: anOssPipe [

	[
		| char |
		char := anOssPipe next.
		self nextPut: char.
		char notNil
	] whileTrue

]

{ #category : #'as yet unclassified' }
GSCPipeLinesReadStream >> currentLineBufferString [
	^ String streamContents: [ :s |
		currentLineBuffer do: [ :each |
			s nextPut: each ] ]
]

{ #category : #testing }
GSCPipeLinesReadStream >> hasBuffered [
	^ currentLineBuffer notNil
]

{ #category : #initialization }
GSCPipeLinesReadStream >> initialize [
	super initialize.
	
	self clearBuffer.
	
	cr := Character cr.
	lf := Character lf.
	lines := OrderedCollection new
]

{ #category : #accessing }
GSCPipeLinesReadStream >> lastLine [
	^ self hasBuffered
		ifTrue: [ self currentLineBufferString ]
		ifFalse: [
			lines ifEmpty: [ '' ] ifNotEmpty: [ lines last ]
		]
]

{ #category : #'as yet unclassified' }
GSCPipeLinesReadStream >> lineComplete [
	| line |
	
	currentLineBuffer ifNil: [ ^ self ].
	
	line := self currentLineBufferString.

	lines add: line.
	
	self clearBuffer
]

{ #category : #accessing }
GSCPipeLinesReadStream >> nextLine [
	lines ifEmpty: [ ^ nil ].
	
	^ lines removeFirst
]

{ #category : #accessing }
GSCPipeLinesReadStream >> nextLines [
	| all |
	
	all := lines copy.

	lines removeAll.
	
	^ all
]

{ #category : #accessing }
GSCPipeLinesReadStream >> nextPut: aCharacter [

	lastCharacter := aCharacter.

	aCharacter ifNil: [ ^ self ].


	"ignore lf after cr"
	(lastCharacter == cr and: [ aCharacter == lf ]) ifTrue: [ ^ self ].

	"At this point we ensure that we have a new line"
	currentLineBuffer ifNil: [ 
		currentLineBuffer := OrderedCollection new ].
	
	"newline if cr or lf"
	(aCharacter == cr or: [ aCharacter == lf ]) ifTrue: [ self lineComplete. ^ self ].
		
	currentLineBuffer add: aCharacter.

]

{ #category : #removing }
GSCPipeLinesReadStream >> removeLastLine [
	self hasBuffered ifTrue: [ self clearBuffer ] ifFalse: [ lines removeLast ]
]
