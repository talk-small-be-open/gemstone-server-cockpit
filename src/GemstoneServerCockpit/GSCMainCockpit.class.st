Class {
	#name : #GSCMainCockpit,
	#superclass : #WAComponent,
	#instVars : [
		'core',
		'selectedToolChain'
	],
	#category : #'GemstoneServerCockpit-View'
}

{ #category : #'as yet unclassified' }
GSCMainCockpit >> checkAll [
	core rootTool check
	
]

{ #category : #initialization }
GSCMainCockpit >> initialize [
	super initialize.
	
	core := GSCCore instance.
"	selectedTools := OrderedCollection new."
	
	self reset
]

{ #category : #testing }
GSCMainCockpit >> isSelectedTool: aTool [
	^ self selectedTools includes: aTool
]

{ #category : #'as yet unclassified' }
GSCMainCockpit >> killShellProcess [
	core killShellProcess 
]

{ #category : #accessing }
GSCMainCockpit >> lastSelectedTool [
	^ self selectedTools atLast: 1 ifAbsent: [ nil ]
]

{ #category : #'as yet unclassified' }
GSCMainCockpit >> reSetup [

	core setup
]

{ #category : #rendering }
GSCMainCockpit >> renderContentOn: html [

	self renderCoreToolbarOn: html.
	
	self renderSubprocessOn: html.

	html div class: 'main'; with: [ 
		html div class: 'upperPane'; with: [
			self renderPanesOn: html
		].
		html div class: 'lowerPane'; with: [
			self renderTheToolOn: html
		].

	]
]

{ #category : #rendering }
GSCMainCockpit >> renderCoreToolbarOn: html [

	html form: [	
		core isSudoPasswordSet ifFalse: [
			html anchor
				callback: [ self setSudoPassword ];
				with: 'Set sudo password ...'
		].

		html textInput
			callback: [ :value | core filesystemRoot: value ];
			with: core filesystemRoot pathString.
		html submitButton: 'Save'.
	
		html space.
		html anchor
			callback: [ self checkAll ];
			with: 'check all'.

		html space.
		html anchor
			callback: [ self reSetup ];
			with: 're-setup'

	]
]

{ #category : #rendering }
GSCMainCockpit >> renderPane: anIndex list: aCollection on: html [
	| selected |
	selected := self selectedInPane: anIndex.

	html div class: 'toolsPane'; with: [	
		aCollection do: [ :each |
			html anchor
				class: 'listEntry';
				class: 'selected' if: (selected = each);
				callback: [ self selectTool: each ];
				with: [
					each renderListEntryOn: html ]
		]
	]
]

{ #category : #rendering }
GSCMainCockpit >> renderPanesOn: html [
	html div class: 'toolsPanes'; with: [
		self rootAndSelectedTools withIndexDo: [ :each :index |
			self renderPane: index list: each children on: html.
		]
	]
]

{ #category : #rendering }
GSCMainCockpit >> renderSubprocessOn: html [

	core isShellProcessRunning ifTrue: [ 
		html div: 'SHELL RUNS!'.
		html anchor
			callback: [ self killShellProcess ];
			with: 'kill'.
		html script: 'setTimeout(function(){ location.reload() }, 5000);'.
		
		html form: [ 
			html textInput
				callback: [ :value | self writeToSubprocess: value ].
			html submitButton ]
	].

]

{ #category : #rendering }
GSCMainCockpit >> renderTheToolOn: html [
	html div: [
		self lastSelectedTool ifNotNil: [ :tool |
			tool renderOn: html ]
	]
]

{ #category : #initialization }
GSCMainCockpit >> reset [
	selectedToolChain := IdentityDictionary new.
]

{ #category : #'as yet unclassified' }
GSCMainCockpit >> rootAndSelectedTools [
	^ OrderedCollection new
		add: core rootTool;
		addAll: self selectedTools;
		yourself
]

{ #category : #'as yet unclassified' }
GSCMainCockpit >> selectTool: aChildTool [
	"If already selected, we deselect the child. Kind of backwards navigating selection"
	(self isSelectedTool: aChildTool) ifTrue: [
		selectedToolChain at: aChildTool put: nil ].

	"Store which child is selected for the parent"
	selectedToolChain at: aChildTool parent put: aChildTool.


]

{ #category : #'as yet unclassified' }
GSCMainCockpit >> selectedInPane: anIndex [
	^ self selectedTools at: anIndex ifAbsent: [ nil ]
]

{ #category : #accessing }
GSCMainCockpit >> selectedTools [
	| this next all |

	this := core rootTool.
	all := OrderedCollection new.

	[
		next := selectedToolChain at: this ifAbsent: [ nil ].
		next ifNotNil: [
			all add: next.
			this := next.
		].

		next notNil.
		
		"TODO infinite loop detection"
	] whileTrue.

	^ all
]

{ #category : #initialization }
GSCMainCockpit >> setSudoPassword [
	| pw |
	pw := self request: 'Password?'.
	core setSudoPassword: pw.
	
	"Check sudo password"
"TODO	(core runSudoShellIsSuccess: 'ls /root') ifFalse: [
		core clearSudoPassword
	]"
]

{ #category : #writing }
GSCMainCockpit >> writeToSubprocess: aString [
	core writeLineToShellProcess: aString
]
