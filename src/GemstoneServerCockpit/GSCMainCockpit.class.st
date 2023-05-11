Class {
	#name : #GSCMainCockpit,
	#superclass : #WAComponent,
	#instVars : [
		'core',
		'selectedToolChain'
	],
	#category : #'GemstoneServerCockpit-View'
}

{ #category : #initialization }
GSCMainCockpit >> initialize [
	super initialize.
	
	core := GSCCore instance.
"	selectedTools := OrderedCollection new."
	
	selectedToolChain := IdentityDictionary new.
]

{ #category : #testing }
GSCMainCockpit >> isSelectedTool: aTool [
	^ self selectedTools includes: aTool
]

{ #category : #'as yet unclassified' }
GSCMainCockpit >> killShellProcess [
	GSCCore instance killShellProcess 
]

{ #category : #accessing }
GSCMainCockpit >> lastSelectedTool [
	^ self selectedTools atLast: 1 ifAbsent: [ nil ]
]

{ #category : #rendering }
GSCMainCockpit >> renderContentOn: html [

	self renderSubprocessOn: html.

	GSCCore instance isSudoPasswordSet ifFalse: [
		html anchor
			callback: [ self setSudoPassword ];
			with: 'Set sudo password ...'
	].

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

	GSCCore instance isShellProcessRunning ifTrue: [ 
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

{ #category : #'as yet unclassified' }
GSCMainCockpit >> rootAndSelectedTools [
	^ OrderedCollection new
		add: GSCCore instance rootTool;
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

	this := GSCCore instance rootTool.
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
	GSCCore instance setSudoPassword: pw
]

{ #category : #writing }
GSCMainCockpit >> writeToSubprocess: aString [
	GSCCore instance writeToShellProcess: (aString, String cr)
]
