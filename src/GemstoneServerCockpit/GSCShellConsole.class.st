Class {
	#name : #GSCShellConsole,
	#superclass : #GSCTool,
	#instVars : [
		'cmd'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCShellConsole >> cmd [

	^ cmd
]

{ #category : #accessing }
GSCShellConsole >> cmd: anObject [

	cmd := anObject
]

{ #category : #'as yet unclassified' }
GSCShellConsole >> doExecute [
	self runShellCommand: cmd
]

{ #category : #'as yet unclassified' }
GSCShellConsole >> doExecuteSudo [
	self runSudoShellCommand: cmd
]

{ #category : #rendering }
GSCShellConsole >> renderBodyOn: html [
	html form: [ 
		html textInput on: #cmd of: self.
		html submitButton
			callback: [ self doExecute ];
			with: 'do'.
		html submitButton
			callback: [ self doExecuteSudo ];
			with: 'sudo'
			
	]
]

{ #category : #accessing }
GSCShellConsole >> title [
	^ 'Shell console'
]
