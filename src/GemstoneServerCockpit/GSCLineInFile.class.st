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
	
	((self core sudoReadFile: self filePath) lines anySatisfy: [ :each | each = line ]) ifFalse: [
		self beNeedsAttention: 'line in file not found' ]
]

{ #category : #'as yet unclassified' }
GSCLineInFile >> doShowFile [
	self uiViewFile: filePath
]

{ #category : #'as yet unclassified' }
GSCLineInFile >> doWriteLine [
	| exists |
	exists := (self core sudoReadFile: self filePath) lines anySatisfy: [ :each | each includesSubstring: search ].

	exists ifTrue: [
		"replace"
		self runSudoShellCommand: ('sed --in-place=bak "s/^.*', search, '.*$/', line, '/" "', filePath pathString, '"')
	] ifFalse: [
		"append"
		self runSudoShellCommand: ('sed --in-place=bak ''$a\', line, ''' "', filePath pathString, '"')
"		self runSudoShellCommand: ('echo ""\n', line, '"" >> ', filePath pathString)"
	]
]

{ #category : #accessing }
GSCLineInFile >> filePath [

	^ filePath
]

{ #category : #accessing }
GSCLineInFile >> filePath: anObject [

	filePath := self core realPathForFile: anObject
]

{ #category : #accessing }
GSCLineInFile >> line [

	^ line
]

{ #category : #accessing }
GSCLineInFile >> line: anObject [

	line := anObject
]

{ #category : #rendering }
GSCLineInFile >> renderBodyOn: html [

	self renderLabel: 'File path' text: filePath pathString on: html.
	self renderLabel: 'Look for' text: search on: html.
	self renderLabel: 'Target line' text: line on: html.
]

{ #category : #accessing }
GSCLineInFile >> search [

	^ search
]

{ #category : #accessing }
GSCLineInFile >> search: anObject [

	search := anObject
]

{ #category : #accessing }
GSCLineInFile >> title [
	^ 'Line in ', filePath pathString, ' (', search, ')'
]
