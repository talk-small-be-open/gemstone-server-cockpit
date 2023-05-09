Class {
	#name : #GSCSystemService,
	#superclass : #GSCTool,
	#instVars : [
		'serviceName'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCSystemService >> checkMe [
	self beNotNeedsAttention.
	
	self isRunning ifFalse: [ ^ self beNeedsAttention: 'Service is not running' ].
	

]

{ #category : #starting }
GSCSystemService >> doStart [
	self runShellCommand: ('service "', serviceName, '" start')
]

{ #category : #starting }
GSCSystemService >> doStop [
	self runShellCommand: ('service "', serviceName, '" stop')
]

{ #category : #starting }
GSCSystemService >> isRunning [
	^ GSCCore instance runShellIsSuccess: ('systemctl is-active --quiet ', serviceName)

]

{ #category : #accessing }
GSCSystemService >> name: aString [
	serviceName := aString
]

{ #category : #rendering }
GSCSystemService >> renderBodyOn: html [

"	self renderLabel: 'File path' text: fileReference pathString on: html"
]

{ #category : #accessing }
GSCSystemService >> title [
	^ 'Service ', serviceName
]
