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
