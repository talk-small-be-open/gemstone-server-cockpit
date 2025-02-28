Class {
	#name : 'GSCApplication',
	#superclass : 'GSCTool',
	#instVars : [
		'appIndex',
		'scheme'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'accessing' }
GSCApplication >> appIndex [
	^ appIndex ifNil: [ GSCConfigError signal: 'appIndex not defined for application' ]
]

{ #category : 'accessing' }
GSCApplication >> application [
	^ self
]

{ #category : 'as yet unclassified' }
GSCApplication >> autogeneratedIndex [
	^ self root autogeneratedAppIndexFor: self
]

{ #category : 'building' }
GSCApplication >> build [

	"Ensure auto generated index exists"
"	self autogeneratedIndex."

	self add: GSCConfigurationEditor then: [ :editor |
		editor
			title: 'App config';
			config: self config.
	].

	self add: GSCFolder then: [ :folder |
		folder name: 'git repositories'.
		
		(self configAt: 'gitRepositories') dataDo: [ :key :conf |
			folder add: GSCGitRepository then: [ :git |
				git
					folderPath: (conf at: 'path');
					branch: (conf at: 'branch');
					url: (conf at: 'url')
			]
		]
	]

]

{ #category : 'accessing' }
GSCApplication >> config [

	^ scheme config
]

{ #category : 'as yet unclassified' }
GSCApplication >> doReConfig [
"	(self uiConfirm: 'Really fully rebuild this application from its config file?') ifTrue: [ "
		self recreateMyself
"	]"
]

{ #category : 'testing' }
GSCApplication >> isBeta [
	^ (self configAt: 'isBeta') = true
]

{ #category : 'as yet unclassified' }
GSCApplication >> longName [
	^ self configAt: 'project:name'
]

{ #category : 'as yet unclassified' }
GSCApplication >> recreateMyself [
	"TODO: Warn if config unsaved?"
	
	"Remove/delete myself"
	self parent removeTool: self.
	
	"Add a new application like myself, with my config"
	scheme buildApplicationToolInto: self core rootTool
]

{ #category : 'rendering' }
GSCApplication >> renderBodyOn: html [
	html heading level2; with: 'Links'.
	(self configAt: 'web:domains') do: [ :eachDomain |
		(self configAt: 'web:appUrlPaths') do: [ :eachPath |
			| url |
			url := WAUrl new.
			(self configAt: 'web:useSsl')
				ifTrue: [ url scheme: 'https' ]
				ifFalse: [ url scheme: 'http' ].
			
			url host: eachDomain.
			url path: { eachPath }.
			
			html div: [ 
				html anchor
					target: '_blank';
					url: url;
					with: url asString ]
		]
	].
	html heading level2; with: 'Remarks'.
	html form: [ 
		html textArea
			style: 'display: block; width: 100%;';
			rows: 20;
			callback: [ :newValue | (self configAt: 'remarks' put: newValue) ];
			value: (self configAt: 'remarks').
		html submitButton
	 ]
	

]

{ #category : 'accessing' }
GSCApplication >> scheme [

	^ scheme
]

{ #category : 'accessing' }
GSCApplication >> scheme: anObject [

	scheme := anObject.
	
	"Try to read the number of the conf filename."
	appIndex := scheme config indexFromFilename
]

{ #category : 'as yet unclassified' }
GSCApplication >> shortCode [
	^ self configAt: 'project:shortCode'
]

{ #category : 'accessing' }
GSCApplication >> title [
	^ self longName
]
