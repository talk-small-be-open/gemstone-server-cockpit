Class {
	#name : #GSCShellCommand,
	#superclass : #GSCTool,
	#instVars : [
		'cmd'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCShellCommand >> cmd [

	^ cmd
]

{ #category : #accessing }
GSCShellCommand >> cmd: anObject [

	cmd := anObject
]

{ #category : #'as yet unclassified' }
GSCShellCommand >> doExecute [
	self runShellCommand: cmd
]
