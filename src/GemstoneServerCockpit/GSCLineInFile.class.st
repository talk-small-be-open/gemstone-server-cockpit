Class {
	#name : #GSCLineInFile,
	#superclass : #GSCTool,
	#instVars : [
		'filePath',
		'search',
		'line'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCLineInFile >> checkMe [
	self beNotNeedsAttention.
	
	(self filePath asFileReference contents lines anySatisfy: [ :each | each = line ]) ifFalse: [ self beNeedsAttention: 'line in file not found' ]
]

{ #category : #'as yet unclassified' }
GSCLineInFile >> doWriteLine [
	| exists |
	exists := (self filePath asFileReference contents lines anySatisfy: [ :each | each beginsWith: search ]).
	
	exists ifTrue: [
		"replace"
		self runSudoShellCommand: ('sed --in-place=bak "s/^', search, '.*$/', line, '/" ', filePath)
	] ifFalse: [
		"append"
		self runSudoShellCommand: ('echo "\n', line, '" >> ', filePath)
	]
]

{ #category : #accessing }
GSCLineInFile >> filePath [

	^ filePath
]

{ #category : #accessing }
GSCLineInFile >> filePath: anObject [

	filePath := anObject
]

{ #category : #accessing }
GSCLineInFile >> line [

	^ line
]

{ #category : #accessing }
GSCLineInFile >> line: anObject [

	line := anObject
]

{ #category : #accessing }
GSCLineInFile >> search [

	^ search
]

{ #category : #accessing }
GSCLineInFile >> search: anObject [

	search := anObject
]
