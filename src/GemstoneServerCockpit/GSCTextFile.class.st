Class {
	#name : #GSCTextFile,
	#superclass : #GSCTool,
	#instVars : [
		'fileReference',
		'shouldContent',
		'contentTemplate',
		'fileContents',
		'owner',
		'group',
		'mode'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCTextFile >> checkMe [
	self beNotNeedsAttention.

	self isExisting ifFalse: [ ^ self beNeedsAttention: 'File does not exist' ].
	
	self readFileContents.
	
"	self fileContents inspect.
	contentTemplate contentString withUnixLineEndings inspect."
	
	self fileContents ~= contentTemplate contentString withUnixLineEndings ifTrue: [ ^ self beNeedsAttention: 'File contents differ' ].
	
	
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
GSCTextFile >> doShowFile [
	self log: contentTemplate contentString
]

{ #category : #'tool-actions' }
GSCTextFile >> doWriteFile [
	fileReference ifNil: [ self log: 'File path not defined'. ^ self ].
	
"	fileReference parent ensureCreateDirectory.
	fileReference ensureDelete."
	
"	fileReference writeStreamEncoded: 'utf-8' do: [ :s |
		s << contentTemplate contentString withUnixLineEndings
	]."

	self core sudoWriteFile: fileReference pathString owner: owner group: group mode: mode with: contentTemplate contentString withUnixLineEndings.

	self log: 'File created'.
	
	self refresh
]

{ #category : #accessing }
GSCTextFile >> fileContents [
	^ fileContents
]

{ #category : #accessing }
GSCTextFile >> filePath: aString [
	
	fileReference := self core realPathForFile: aString.
	
"	self log: 'File: ', fileReference pathString"
	
]

{ #category : #'private - initialization' }
GSCTextFile >> initMe [
	super initMe.
"	self isExisting ifFalse: [ self log: 'File does not exist' ] ifTrue: [
		self log: 'Current content is:'.
		self log: fileReference contents ]"
]

{ #category : #initialization }
GSCTextFile >> initialize [
	super initialize.
	
	mode := 'u=rwx,g=rx'.
	owner := 'root'.
	group := 'root'.
]

{ #category : #testing }
GSCTextFile >> isExisting [
	^ fileReference notNil and: [ fileReference exists ]
]

{ #category : #accessing }
GSCTextFile >> readFileContents [
	"sudo, has always permission"
	fileContents := self core sudoReadFile: fileReference pathString
]

{ #category : #rendering }
GSCTextFile >> renderBodyOn: html [

	self renderLabel: 'File path' text: fileReference pathString on: html.
	
	html table: [ 
		html tableRow: [ 
			html tableHeading: 'IST'.
			html tableHeading: 'SOLL' ].
		html tableRow: [ 
			html tableData: [
				self isExisting ifTrue: [
					html preformatted
						class: 'fileContent';
						with: self fileContents ].
			].
			html tableData: [ 
				html preformatted
					class: 'fileContent';
					with: self contentTemplate contentString ]
		]
	]
]

{ #category : #accessing }
GSCTextFile >> title [
	^ fileReference basename
]
