Class {
	#name : #GSCShellCommand,
	#superclass : #GSCTool,
	#instVars : [
		'cmd',
		'checkMeBlock',
		'title'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCShellCommand >> checkMe [
	self beNotNeedsAttention.
	
	checkMeBlock ifNotNil: [ checkMeBlock cull: self ]
]

{ #category : #accessing }
GSCShellCommand >> checkMeBlock [

	^ checkMeBlock
]

{ #category : #accessing }
GSCShellCommand >> checkMeBlock: anObject [

	checkMeBlock := anObject
]

{ #category : #accessing }
GSCShellCommand >> cmd [

	^ cmd
]

{ #category : #accessing }
GSCShellCommand >> cmd: anObject [

	cmd := anObject
]

{ #category : #'as yet unclassified' }
GSCShellCommand >> depotScript: aScriptName [
	^ self depotScript: aScriptName args: nil

]

{ #category : #'as yet unclassified' }
GSCShellCommand >> depotScript: aScriptName args: anArgsString [
	| command |
	command := (self core fileDepotScriptsDir / aScriptName) pathString.
	
	anArgsString ifNotBlank: [ command := command, ' ', anArgsString ].
	
	self cmd: command
]

{ #category : #'as yet unclassified' }
GSCShellCommand >> doExecute [
	self runShellCommand: cmd
]

{ #category : #rendering }
GSCShellCommand >> renderBodyOn: html [
	self renderLabel: 'Command' text: self cmd on: html.
]

{ #category : #accessing }
GSCShellCommand >> title [
	^ 'Shell: ', (title ifBlank: [ cmd ])
]

{ #category : #accessing }
GSCShellCommand >> title: aString [
	title := aString
]
