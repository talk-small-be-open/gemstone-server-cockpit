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

	self renderLogoOn: html.

	html div class: 'mainTitle'; with: 'GemStone Server Cockpit'.
	
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

	html div class: 'coreToolbar'; with: [
		html form: [	
			core isSudoPasswordSet ifFalse: [
				html anchorButton
					callback: [ self setSudoPassword ];
					with: 'Set sudo password ...'
			].

			html textInput
				callback: [ :value | core filesystemRoot: value ];
				with: core filesystemRoot pathString.
			html submitButton: 'Save'.
		
			html anchorButton
				callback: [ self checkAll ];
				with: 'Check all'.

			html anchorButton
				callback: [ self reSetup ];
				with: 'Re-setup'

		] ]
]

{ #category : #rendering }
GSCMainCockpit >> renderLogoOn: html [
	html html: '<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 276.316 276.316" style="position: absolute; right: 10px; top: 10px; width: 100px;" xml:space="preserve">
<g>
	<polygon style="fill:#FFE49C;" points="7.5,107.293 268.817,107.293 199.899,43.566 	"/>
	<path style="fill:#FFE49C;" d="M7.5,107.293V232.75h149.758c0-24.023,19.475-43.498,43.498-43.498s43.498,19.475,43.498,43.498
		h24.563V107.293H7.5z"/>
	<circle style="fill:#F59D00;" cx="49.45" cy="178.833" r="15.965"/>
	<circle style="fill:#F59D00;" cx="131.873" cy="154.401" r="18.904"/>
	<g>
		<path style="fill:#F59D00;" d="M268.817,177.651V126.24c-2.498-0.767-5.151-1.182-7.9-1.182
			c-14.849,0-26.887,12.038-26.887,26.887s12.038,26.887,26.887,26.887C263.666,178.833,266.318,178.418,268.817,177.651z"/>
		<g>
			<path style="fill:#414042;" d="M273.908,101.787l-68.917-63.728c-2.004-1.853-4.858-2.471-7.45-1.612L5.287,100.126
				C2.11,101.131,0,104.033,0,107.294V232.75c0,4.143,3.358,7.5,7.5,7.5h149.758c4.142,0,7.5-3.357,7.5-7.5
				c0-19.85,16.148-35.998,35.998-35.998c19.849,0,35.997,16.148,35.997,35.998c0,4.143,3.358,7.5,7.5,7.5h24.563
				c4.142,0,7.5-3.357,7.5-7.5v-55.099v-51.41v-18.947C276.316,105.149,275.383,103.157,273.908,101.787z M261.316,171.329
				c-10.801,0.237-19.787-8.51-19.787-19.383c0-10.865,8.978-19.62,19.787-19.383V171.329z M198.057,52.077l51.602,47.717H53.996
				L198.057,52.077z M251.203,225.25c-3.637-24.578-24.874-43.498-50.447-43.498s-46.811,18.92-50.448,43.498H15V114.794h246.316
				v2.781c-19.094-0.244-34.787,15.238-34.787,34.372c0,19.054,15.611,34.617,34.787,34.372v38.932h-10.113V225.25z"/>
			<path style="fill:#414042;" d="M49.45,155.368c-12.939,0-23.465,10.526-23.465,23.465s10.526,23.466,23.465,23.466
				s23.465-10.526,23.465-23.466C72.915,165.894,62.389,155.368,49.45,155.368z M49.45,187.299c-4.668,0-8.465-3.798-8.465-8.466
				s3.797-8.465,8.465-8.465s8.465,3.797,8.465,8.465S54.118,187.299,49.45,187.299z"/>
			<path style="fill:#414042;" d="M131.873,127.997c-14.56,0-26.404,11.845-26.404,26.404s11.845,26.404,26.404,26.404
				c14.56,0,26.405-11.845,26.405-26.404C158.278,139.842,146.433,127.997,131.873,127.997z M131.873,165.805
				c-6.288,0-11.404-5.116-11.404-11.404s5.116-11.404,11.404-11.404c6.289,0,11.405,5.116,11.405,11.404
				S138.162,165.805,131.873,165.805z"/>
		</g>
	</g>
</g>
</svg>'

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
		html div class: 'subprocess'; with: [
			html div: 'SHELL RUNS!'.
			html anchorButton
				callback: [ self killShellProcess ];
				with: 'Kill Pharo process'.
			html script: 'setTimeout(function(){ location.reload() }, 5000);'.
			
			html form: [ 
				html textInput
					callback: [ :value | self writeLineToSubprocess: value ].
				html submitButton ].
			
			html anchorButton callback: [ self writeToSubprocess: Character end ]; with: 'Send Ctrl-D (EOF)'.
			html space.
			html anchorButton callback: [ self writeToSubprocess: Character enter ]; with: 'Send Ctrl-C (INT)'.
			html space.

		core subprocessTailLines ifNotBlank: [ :lines |
			html preformatted: [
				lines do: [ :each | html text: each ] separatedBy: [ html text: Character lf ].
		]]

		] ].

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
	(core runSudoShellIsSuccess: 'cat /etc/sudoers') ifFalse: [
		core clearSudoPassword
	]
]

{ #category : #writing }
GSCMainCockpit >> writeLineToSubprocess: aString [
	core writeLineToShellProcess: aString
]

{ #category : #writing }
GSCMainCockpit >> writeToSubprocess: aString [
	core writeToShellProcess: aString
]
