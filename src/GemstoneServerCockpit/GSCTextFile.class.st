Class {
	#name : #GSCTextFile,
	#superclass : #GSCTool,
	#instVars : [
		'fileReference',
		'shouldContent',
		'contentTemplate'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCTextFile >> checkMe [
	self beNotNeedsAttention.

	self isExisting ifFalse: [ ^ self beNeedsAttention: 'File does not exist' ].
	
	fileReference contents ~= contentTemplate contentString withUnixLineEndings ifTrue: [ ^ self beNeedsAttention: 'File contents differ' ]
]

{ #category : #accessing }
GSCTextFile >> contentTemplate [

	^ contentTemplate
]

{ #category : #accessing }
GSCTextFile >> contentTemplate: anObject [

	contentTemplate := anObject
]

{ #category : #'tool-actions' }
GSCTextFile >> doWriteFile [
	fileReference ifNil: [ self log: 'File path not defined'. ^ self ].
	
	fileReference parent ensureCreateDirectory.
	fileReference ensureDelete.
	
	fileReference writeStreamEncoded: 'utf-8' do: [ :s |
		s << contentTemplate contentString withUnixLineEndings
	].

	self log: 'File created'.
	
	self refresh
]

{ #category : #accessing }
GSCTextFile >> filePath: aString [
	
	fileReference := GSCCore instance realPathForFile: aString.
	
	self log: 'File: ', fileReference pathString
	
]

{ #category : #'private - initialization' }
GSCTextFile >> initMe [
	self isExisting ifFalse: [ self log: 'File does not exist' ] ifTrue: [
		self log: 'Current content is:'.
		self log: fileReference contents ]
]

{ #category : #testing }
GSCTextFile >> isExisting [
	^ fileReference notNil and: [ fileReference exists ]
]

{ #category : #accessing }
GSCTextFile >> title [
	^ fileReference basename
]
