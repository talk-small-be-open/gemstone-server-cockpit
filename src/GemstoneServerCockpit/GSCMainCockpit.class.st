Class {
	#name : 'GSCMainCockpit',
	#superclass : 'WAComponent',
	#instVars : [
		'core',
		'selectedToolChain'
	],
	#category : 'GemstoneServerCockpit-View',
	#package : 'GemstoneServerCockpit',
	#tag : 'View'
}

{ #category : 'as yet unclassified' }
GSCMainCockpit >> checkAll [
	core doInBackground: [
		core rootTool check ]
	
]

{ #category : 'accessing' }
GSCMainCockpit >> currentTool [
	^ self selectedTools atLast: 1 ifAbsent: [ nil ]
]

{ #category : 'as yet unclassified' }
GSCMainCockpit >> editText: aString then: aBlock [
	| editor |
	editor := (GSCTextEditor content: aString).
	
	self show: editor onAnswer: [:answer |
		answer ~= #cancel ifTrue: [
			aBlock value: editor content
		]
	]
]

{ #category : 'initialization' }
GSCMainCockpit >> gotoHome [
	selectedToolChain := IdentityDictionary new.
]

{ #category : 'initialization' }
GSCMainCockpit >> initialize [
	super initialize.
	
	core := GSCCore instance.
"	selectedTools := OrderedCollection new."
	
	self gotoHome
]

{ #category : 'testing' }
GSCMainCockpit >> isSelectedTool: aTool [
	^ self selectedTools includes: aTool
]

{ #category : 'as yet unclassified' }
GSCMainCockpit >> killShellProcess [
	core killShellProcess 
]

{ #category : 'as yet unclassified' }
GSCMainCockpit >> reSetup [
	(self confirm: 'This will destroy all non-saved configurations and reload the config from the files. Continue?') ifTrue: [
		core setup ]
]

{ #category : 'rendering' }
GSCMainCockpit >> renderContentOn: html [

	self renderLogoOn: html.

	html div class: 'mainTitle'; with: 'GemStone Server Cockpit'.
	
	html div: self rootTool hostname.
	
	self renderCoreToolbarOn: html.
"	self renderRootToolbarOn: html."

	self renderSubprocessOn: html.

	html div class: 'main'; with: [ 
		html div class: 'upperPane'; with: [
			self renderPanesOn: html
		].
		html div class: 'lowerPane'; with: [
			self renderTheToolOn: html.
			self renderSubprocessLogOn: html.
		].

	]
]

{ #category : 'rendering' }
GSCMainCockpit >> renderCoreToolbarOn: html [

	html div class: 'coreToolbar'; with: [
		html form: [	
			core needsSudoPassword ifTrue: [
				html anchorButton
					callback: [ self setSudoPassword ];
					with: 'Set sudo password ...'
			].
		
			html anchorButton
				callback: [ self gotoHome ];
				with: 'Home'.

			html anchorButton
				callback: [ self checkAll ];
				with: 'Check all'.

			html anchorButton
				callback: [ self reSetup ];
				with: 'Re-Config'.

			html span: ' Base path: '.
			html textInput
				callback: [ :value | core filesystemRoot: value ];
				with: core filesystemRoot pathString.
			core filesystemRoot isRoot ifFalse: [ html span: ' NON-ROOT! ' ].
			html submitButton: 'Save'.

		].


	]
]

{ #category : 'rendering' }
GSCMainCockpit >> renderLogoOn: html [
	html span
		class: 'gscLogo';
		style: 'position: absolute; right: 10px; top: 10px;';
		with: [
			html div: 'GSC "Jessy"'.
			html div: 'digs & barks'.
			html div
				style: 'width: 75px';
				with: [
					html html: '
<svg
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    id="svg2"
    viewBox="0 0 293.33 393.31"
    version="1.0"
	style=""
  >
  <g
      id="layer1"
      transform="translate(-179.08 -298.51)"
    >
    <path
        id="path3205"
        style="stroke-linejoin:round;fill-rule:evenodd;stroke:#000000;stroke-width:4;fill:#784421"
        d="m322.08 376.02c1.5-30.5 39-75 45.5-75.5s-14 70.5-19.5 75.5-25.5 1.5-26 0z"
    />
    <path
        id="path3257"
        style="fill-rule:evenodd;fill:#000000;fill-opacity:.31373"
        d="m188.5 2c-0.52 0.0397-1.25 0.3727-2.12 0.9375-0.96 13.17-22.91 66.266-28.16 70.124-2.96 2.178-9.25 1.941-14.88 0.938-0.15 1.18-0.28 2.356-0.34 3.5 0.5 1.5 20.5 5 26 0s26-76 19.5-75.5z"
        transform="translate(179.08 298.51)"
    />
    <path
        id="path2383"
        style="stroke-linejoin:round;stroke:#000000;stroke-linecap:round;stroke-width:2.2041;fill:#a05a2c"
        d="m403.52 522.31a67.988 67.988 0 1 1 -135.97 0 67.988 67.988 0 1 1 135.97 0z"
        transform="matrix(1.8148 0 0 1.8148 -283.47 -459.58)"
    />
    <path
        id="path3276"
        style="fill:#000000;fill-opacity:.31373"
        d="m403.52 522.31a67.988 67.988 0 1 1 -135.97 0 67.988 67.988 0 1 1 135.97 0z"
        transform="matrix(1.403 0 0 1.403 -140.29 -263.97)"
    />
    <path
        id="path3339"
        style="fill:#000000;fill-opacity:.31373"
        d="m434.03 429.69c3.2 10.97 4.91 22.59 4.91 34.59 0 68.11-55.27 123.38-123.38 123.38-46.82 0-87.6-26.14-108.5-64.6 15.03 51.2 62.37 88.63 118.41 88.63 68.11 0 123.37-55.27 123.37-123.38 0-21.21-5.37-41.18-14.81-58.62z"
    />
    <path
        id="path3235"
        style="stroke-linejoin:round;stroke:#000000;stroke-linecap:round;stroke-width:4;fill:#a05a2c"
        d="m409.5 608.24c0 21.54-17.48 20.77-39.03 20.77-21.54 0-39.03 0.77-39.03-20.77 0-21.55 17.49-39.03 39.03-39.03 21.55 0 39.03 17.48 39.03 39.03z"
    />
    <path
        id="path3238"
        style="stroke-linejoin:round;stroke:#000000;stroke-linecap:round;stroke-width:4;fill:#a05a2c"
        d="m319.48 608.24c0 21.54-17.48 20.77-39.03 20.77-11.98 0-22.7 0.24-29.86-3.25-5.72-2.79-9.17-7.96-9.17-17.52 0-21.55 17.49-39.03 39.03-39.03 21.55 0 39.03 17.48 39.03 39.03z"
    />
    <g
        id="g3263"
        transform="matrix(-1 0 0 1 652.15 -2.8284)"
      >
      <path
          id="path3265"
          style="stroke:#000000;stroke-linecap:round;stroke-width:4;fill:none"
          d="m357.34 628.69c-3.5-11.33 0.5-24.55 0.5-24.55"
      />
      <path
          id="path3267"
          style="stroke:#000000;stroke-linecap:round;stroke-width:4;fill:none"
          d="m375.37 631.21c4.29-18.25-0.62-32.73-0.62-32.73"
      />
      <path
          id="path3269"
          style="stroke:#000000;stroke-linecap:round;stroke-width:4;fill:none"
          d="m393.62 629.32c8.81-13.85 1.26-25.18 1.26-25.18"
      />
    </g
    >
    <path
        id="path2418"
        style="stroke-linejoin:round;stroke:#000000;stroke-linecap:round;stroke-width:2.8511;fill:#a05a2c"
        d="m403.52 522.31a67.988 67.988 0 1 1 -135.97 0 67.988 67.988 0 1 1 135.97 0z"
        transform="matrix(1.403 0 0 1.403 -145.29 -277.47)"
    />
    <path
        id="path3251"
        style="fill:#000000;fill-opacity:.31373"
        d="m233.44 117.75c1.52 6.77 2.34 13.8 2.34 21.03 0 52.65-42.75 95.41-95.4 95.41-38.78 0-72.158-23.19-87.068-56.44 9.556 42.59 47.608 74.44 93.068 74.44 52.65 0 95.4-42.76 95.4-95.41 0-13.91-2.98-27.11-8.34-39.03z"
        transform="translate(179.08 298.51)"
    />
    <path
        id="path2387"
        style="stroke-linejoin:round;stroke:#000000;stroke-linecap:round;stroke-width:9.931;fill:#ffffff"
        d="m403.52 522.31a67.988 67.988 0 1 1 -135.97 0 67.988 67.988 0 1 1 135.97 0z"
        transform="matrix(.40278 0 0 .40278 158.81 226.93)"
    />
    <path
        id="path2391"
        style="stroke-linejoin:round;stroke:#000000;stroke-linecap:round;stroke-width:9.931;fill:#ffffff"
        d="m403.52 522.31a67.988 67.988 0 1 1 -135.97 0 67.988 67.988 0 1 1 135.97 0z"
        transform="matrix(.40278 0 0 .40278 222.39 226.93)"
    />
    <path
        id="path2393"
        style="fill:#000000"
        d="m403.52 522.31a67.988 67.988 0 1 1 -135.97 0 67.988 67.988 0 1 1 135.97 0z"
        transform="matrix(.125 0 0 .125 260.2 375.16)"
    />
    <path
        id="path2395"
        style="fill:#000000"
        d="m403.52 522.31a67.988 67.988 0 1 1 -135.97 0 67.988 67.988 0 1 1 135.97 0z"
        transform="matrix(.125 0 0 .125 306.78 375.16)"
    />
    <path
        id="path2397"
        style="fill:#000000"
        d="m350.81 501.75c0 13.77-15.08 24.95-25.07 24.95-10.75 0-25.06-11.18-25.06-24.95 0-13.78 11.23-17.28 25.06-17.28 13.84 0 25.07 3.5 25.07 17.28z"
    />
    <path
        id="path3327"
        style="fill:#000000;fill-opacity:.31373"
        d="m390.97 575.03c4.72 6.48 7.53 14.47 7.53 23.09 0 12.47-5.84 23.56-14.91 30.76 15.09-0.58 25.91-3.7 25.91-20.63 0-14.03-7.41-26.34-18.53-33.22z"
    />
    <g
        id="g2410"
        transform="translate(-.14728 -2.8284)"
      >
      <path
          id="path2412"
          style="stroke:#000000;stroke-linecap:round;stroke-width:4;fill:none"
          d="m357.34 628.69c-3.5-11.33 0.5-24.55 0.5-24.55"
      />
      <path
          id="path2414"
          style="stroke:#000000;stroke-linecap:round;stroke-width:4;fill:none"
          d="m375.37 631.21c4.29-18.25-0.62-32.73-0.62-32.73"
      />
      <path
          id="path2416"
          style="stroke:#000000;stroke-linecap:round;stroke-width:4;fill:none"
          d="m393.62 629.32c8.81-13.85 1.26-25.18 1.26-25.18"
      />
    </g
    >
    <path
        id="path3332"
        style="fill:#000000;fill-opacity:.31373"
        d="m300.47 575.03c4.72 6.48 7.53 14.47 7.53 23.09 0 12.47-5.84 23.56-14.91 30.76 15.09-0.58 25.91-3.7 25.91-20.63 0-14.03-7.41-26.34-18.53-33.22z"
    />
    <path
        id="path3349"
        style="fill:#000000;fill-opacity:.31373"
        d="m336.66 588.75c-3.32 5.73-5.22 12.41-5.22 19.5 0 17.51 11.55 20.26 27.44 20.69-15.78-6.58-23.81-22.21-22.22-40.19z"
    />
    <path
        id="path3201"
        style="stroke-linejoin:round;fill-rule:evenodd;stroke:#000000;stroke-width:4;fill:#784421"
        d="m258.29 386.52c-54.92-3.88-83.53 62.3-76.03 81.8 6.1 15.85 39.79 31.84 38.43 17.3-4.41-47.18 54.73-97.89 37.6-99.1z"
    />
    <path
        id="path3203"
        style="stroke-linejoin:round;fill-rule:evenodd;stroke:#000000;stroke-width:4;fill:#784421"
        d="m393.2 386.52c54.92-3.88 83.53 62.3 76.03 81.8-6.1 15.85-39.79 31.84-38.43 17.3 4.41-47.18-54.73-97.89-37.6-99.1z"
    />
    <path
        id="path3262"
        style="fill-rule:evenodd;fill:#000000;fill-opacity:.31373"
        d="m219.19 87.844c50.9 10.295 64.66 77.406 53.75 94.536-2.42 3.79-6.76 7.18-11.72 9.9 10.08-2.33 25.07-12.41 28.94-22.47 7.26-18.89-19.37-81.588-70.97-81.966z"
        transform="translate(179.08 298.51)"
    />
    <path
        id="path3288"
        style="stroke-linejoin:round;fill-rule:evenodd;stroke:#000000;stroke-width:4;fill:#e3dbdb"
        d="m290.79 670.83l72.77-15.76s12.42 19.95 26.82 8.58c14.39-11.37-5.74-22.66-5.74-22.66s20.21-11.03 0.34-20.94c-19.87-9.9-26.5 15.83-26.5 15.83l-70.52 12.45s-18.34-24.58-31.82-8.35c-13.47 16.23 5.02 26.4 5.02 26.4s-14.83 12.89 4.08 21.53c18.92 8.65 24.56-14.73 25.55-17.08z"
    />
    <path
        id="path3300"
        style="fill-rule:evenodd;fill:#000000;fill-opacity:.31373"
        d="m277.36 638.23c1.97 1.89 3.83 3.82 5.64 5.45 0.24-0.04 0.47-0.09 0.71-0.13-1.74-1.74-3.9-3.67-6.35-5.32zm108.92-17.49c0.34 0.46 0.64 0.95 0.92 1.45 2.01 6.02-6.4 10.95-9.51 14.3 1.13 2.21 3.89 3.67 6.12 5.58 1.91-1.1 19.07-12.18 2.47-21.33zm-134.02 35.93c0.91 2.23 2.31 4.13 3.74 5.62 1.9-2.26-1.57-3.8-3.74-5.62zm134.14-14.55c0.44 0.51 0.82 1.09 1.12 1.7 6.03 7.71-3.98 17.18-11.88 16.69-7.76-0.17-10.84-7.66-15.72-12.38-24.26 5.25-50.26 10.84-74.52 16.09-2.47 4.05-3.34 9.33-6.64 13.06-4.95 7.84-15.94 7.03-22.56 1.67-0.13-0.07-0.24-0.17-0.36-0.25 0.67 3.13 3.25 6.4 9.41 9.22 18.92 8.65 24.55-14.74 25.54-17.09l74.52-16.09s10.69 20.29 25.08 8.92c11.7-9.24 0.58-18.42-3.99-21.54z"
    />
  </g
  >
  <metadata
    >
    <rdf:RDF
      >
      <cc:Work
        >
        <dc:format
          >image/svg+xml</dc:format
        >
        <dc:type
            rdf:resource="http://purl.org/dc/dcmitype/StillImage"
        />
        <cc:license
            rdf:resource="http://creativecommons.org/licenses/publicdomain/"
        />
        <dc:publisher
          >
          <cc:Agent
              rdf:about="http://openclipart.org/"
            >
            <dc:title
              >Openclipart</dc:title
            >
          </cc:Agent
          >
        </dc:publisher
        >
      </cc:Work
      >
      <cc:License
          rdf:about="http://creativecommons.org/licenses/publicdomain/"
        >
        <cc:permits
            rdf:resource="http://creativecommons.org/ns#Reproduction"
        />
        <cc:permits
            rdf:resource="http://creativecommons.org/ns#Distribution"
        />
        <cc:permits
            rdf:resource="http://creativecommons.org/ns#DerivativeWorks"
        />
      </cc:License>
    </rdf:RDF>
  </metadata>
</svg>
'
]]
]

{ #category : 'rendering' }
GSCMainCockpit >> renderPane: anIndex head: aHeadTool list: aCollection on: html [
	| selected |

	aCollection ifBlank: [ ^ self ].
	
	selected := self selectedInPane: anIndex.

	html div class: 'toolsPane'; with: [	
		"Pseudo entry of the parent tool, so that we do not overlook it"
		html anchor
			class: 'listEntry main';
			class: 'selected' if: (selected isNil);
			callback: [ self selectTool: aHeadTool ];
			with: [
				aHeadTool renderListHeadEntryOn: html ].

		"Render the children list of tools"
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

{ #category : 'rendering' }
GSCMainCockpit >> renderPanesOn: html [
	html div class: 'toolsPanes'; with: [
		self selectedTools withIndexDo: [ :each :index |
			| paneNumber |
			paneNumber := index.
			self renderPane: paneNumber head: each list: each children on: html.
		]
	]
]

{ #category : 'rendering' }
GSCMainCockpit >> renderRootToolbarOn: html [
	html div: [
		self rootTool renderOn: html ]
	
"oder nur renderActionsOn: html"

]

{ #category : 'rendering' }
GSCMainCockpit >> renderSubprocessLogOn: html [
	core subprocessTailLines ifNotBlank: [ :lines |
		html heading level1; with: 'Last subprocess output'.
		html preformatted class: 'lastLogEntries'; with: [
			lines do: [ :each | html text: each ] separatedBy: [ html text: Character lf ].
	]]

]

{ #category : 'rendering' }
GSCMainCockpit >> renderSubprocessOn: html [

	core isShellProcessPresent ifTrue: [
		html div class: 'subprocess'; with: [
			html heading level2; with: 'SHELL COMMAND IS RUNNING!'.
			html div class: 'command'; with: core subprocessCommandLabel.
			html anchorButton
				callback: [ self killShellProcess ];
				with: 'Hard abort'.
			html script: 'setTimeout(function(){ location.reload() }, 1899);'.
			
			html form: [ 
				html textInput
					callback: [ :value | self writeLineToSubprocess: value ].
				html submitButton: 'Send text' ].
			
			html anchorButton callback: [ self writeToSubprocess: Character end ]; with: 'Send Ctrl-D (EOF)'.
			html space.
			html anchorButton callback: [ self writeToSubprocess: Character enter ]; with: 'Send Ctrl-C (INT)'.
			html space.

		html heading level3; with: 'Output'.
		core subprocessTailLines ifNotBlank: [ :lines |
			html preformatted class: 'lastLogEntries'; with: [
				(lines lastAtMost: 30) do: [ :each | html text: each ] separatedBy: [ html text: Character lf ].
		]]

		] ].

]

{ #category : 'rendering' }
GSCMainCockpit >> renderTheToolOn: html [
	html div: [
		self currentTool ifNotNil: [ :tool |
			tool renderOn: html ]
	]
]

{ #category : 'accessing' }
GSCMainCockpit >> rootTool [
	^ core rootTool
]

{ #category : 'as yet unclassified' }
GSCMainCockpit >> selectTool: aChildTool [
	"If already selected, we deselect the child. Kind of backwards navigating selection"
	(self isSelectedTool: aChildTool) ifTrue: [
		selectedToolChain at: aChildTool put: nil ].

	"Store which child is selected for the parent"
	selectedToolChain at: aChildTool parent put: aChildTool.


]

{ #category : 'as yet unclassified' }
GSCMainCockpit >> selectedInPane: anIndex [
	^ self selectedTools at: anIndex + 1 ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GSCMainCockpit >> selectedTools [
	| this next all |

	"By definition, the root tool is always selected. Its the start, the home."

	this := core rootTool.
	all := OrderedCollection new.
	
	[
		all add: this.
		next := selectedToolChain at: this ifAbsent: [ nil ].
		next ifNotNil: [
"			all add: next."
			this := next.
		].

		next notNil.
		
		"TODO infinite loop detection"
	] whileTrue.

	^ all
]

{ #category : 'initialization' }
GSCMainCockpit >> setSudoPassword [
	| pw |
	pw := self request: 'Password?'.
	core setSudoPassword: pw.
	
	"Check sudo password"
	(core runSudoShellIsSuccess: 'cat /etc/sudoers') ifFalse: [
		core clearSudoPassword
	]
]

{ #category : 'as yet unclassified' }
GSCMainCockpit >> showFullscreen: aRenderable [
	self show: aRenderable
]

{ #category : 'updating' }
GSCMainCockpit >> updateRoot: anHtmlRoot [
	super updateRoot: anHtmlRoot.
	
	anHtmlRoot title: 'GSC GemStone Server Cockpit'
]

{ #category : 'as yet unclassified' }
GSCMainCockpit >> viewText: aString then: aBlock [
	| editor |
	editor := (GSCTextViewer content: aString).
	
	self show: editor onAnswer: [:answer |
		aBlock value
	]
]

{ #category : 'writing' }
GSCMainCockpit >> writeLineToSubprocess: aString [
	core writeLineToShellProcess: aString
]

{ #category : 'writing' }
GSCMainCockpit >> writeToSubprocess: aString [
	core writeToShellProcess: aString
]
