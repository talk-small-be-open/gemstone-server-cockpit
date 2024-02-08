Class {
	#name : #GSCTextFile,
	#superclass : #GSCTool,
	#instVars : [
		'shouldContent',
		'contentTemplate',
		'fileContents',
		'owner',
		'group',
		'mode',
		'filePath',
		'title',
		'fileDiff'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCTextFile >> beRootOwned [
	owner := 'root'.
	group := 'root'.
	mode := 'u=rw'
]

{ #category : #'as yet unclassified' }
GSCTextFile >> beUserOwned [
	owner := self serverUsername.
	group := self serverGroupname.
	mode := 'u=rw,g=rw'
]

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

{ #category : #'as yet unclassified' }
GSCTextFile >> doEditFile [
	self uiEditText: self fileContents then: [ :newText |.
		self writeFileContents: newText
	]
]

{ #category : #'tool-actions' }
GSCTextFile >> doGetDiff [

"	fileDiff := (TextDiffBuilder buildDisplayPatchFrom: self fileContents to: self contentTemplate contentString)"

	fileDiff := OrderedCollection new.

	self core
		runShell: 'diff'
		args: { '--side-by-side'. '--left-column'. '--strip-trailing-cr'. '--text'. '--ignore-tab-expansion'. '--ignore-space-change'. '--ignore-all-space'. '--ignore-blank-lines'. filePath pathString. '-' }
		stdin: self contentTemplate contentString
		sudo: false
		onOutput: [ :newLines | fileDiff addAll: newLines ]
		onRun: nil
		onFinish: nil.
]

{ #category : #'tool-actions' }
GSCTextFile >> doWriteTemplate [
	self writeFileContents: contentTemplate contentString
]

{ #category : #accessing }
GSCTextFile >> fileContents [
	fileContents ifNil: [ self readFileContents ].
	
	^ fileContents
]

{ #category : #accessing }
GSCTextFile >> filePath: aString [
	
	filePath := self core realPathForFile: aString.
	
"	self log: 'File: ', fileReference pathString"
	
]

{ #category : #accessing }
GSCTextFile >> group [

	^ group
]

{ #category : #accessing }
GSCTextFile >> group: anObject [

	group := anObject
]

{ #category : #'private - initialization' }
GSCTextFile >> initMe [
	super initMe.
"	self isExisting ifFalse: [ self log: 'File does not exist' ] ifTrue: [
		self log: 'Current content is:'.
		self log: fileReference contents ]"
	
"	mode := 'u=rwx,g=rx'."
	owner ifBlank: [
		owner := self serverUsername ].
	group ifBlank: [
		group := self serverGroupname ].
]

{ #category : #initialization }
GSCTextFile >> initialize [
	super initialize.
	
	self beRootOwned
]

{ #category : #testing }
GSCTextFile >> isExisting [
	^ filePath notNil and: [
		self core fileExists: filePath ]
]

{ #category : #accessing }
GSCTextFile >> mode [

	^ mode
]

{ #category : #accessing }
GSCTextFile >> mode: anObject [

	mode := anObject
]

{ #category : #accessing }
GSCTextFile >> owner [

	^ owner
]

{ #category : #accessing }
GSCTextFile >> owner: anObject [

	owner := anObject
]

{ #category : #accessing }
GSCTextFile >> readFileContents [
	"sudo, has always permission"
	fileContents := self core sudoReadFile: filePath
]

{ #category : #rendering }
GSCTextFile >> renderBodyOn: html [

	self renderLabel: 'File path' text: filePath pathString on: html.
	
	html div class: 'horizontalScroll'; with: [
		html table class: 'fileComparison'; with: [ 
			html tableRow: [ 
				html tableHeading: 'ON DISK'.
				html tableHeading: 'TEMPLATE' ].
			html tableRow: [ 
				html tableData: [
					html preformatted
						class: 'fileContent';
						with: self fileContents.
				].
				html tableData: [ 
					html preformatted
						class: 'fileContent';
						with: self contentTemplate contentString ]
			].
		
			fileDiff ifNotBlank: [
				html tableRow: [
					html tableData colSpan: 2; with: [
						html preformatted
							with: [
								fileDiff do: [ :each |
									html text: each.
									html text: String lf
							].
								
								] ]
				].
			]
		] ] 
]

{ #category : #accessing }
GSCTextFile >> title [
	^ title ifBlank: [ filePath basename ]
]

{ #category : #accessing }
GSCTextFile >> title: anObject [

	title := anObject
]

{ #category : #'tool-actions' }
GSCTextFile >> writeFileContents: aString [

	filePath ifNil: [ self log: 'File path not defined'. ^ self ].
	
"	fileReference parent ensureCreateDirectory.
	fileReference ensureDelete."
	
"	fileReference writeStreamEncoded: 'utf-8' do: [ :s |
		s << contentTemplate contentString withUnixLineEndings
	]."

	fileDiff := nil.

	self core sudoEnsureDirectory: filePath parent owner: self serverUsername group: self serverUsername mode: 'u=rwx,g=rwx,o=rx' then: [
		self core sudoAsyncWriteFile: filePath owner: owner group: group mode: mode with: aString then: [
			self log: 'File created'.
			self refresh ] ]
]
