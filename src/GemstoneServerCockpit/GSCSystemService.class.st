Class {
	#name : 'GSCSystemService',
	#superclass : 'GSCTool',
	#instVars : [
		'serviceName'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'as yet unclassified' }
GSCSystemService >> checkMe [
	self beNotNeedsAttention.
	
	self isRunning ifFalse: [ ^ self beNeedsAttention: 'Service is not running' ].
	

]

{ #category : 'starting' }
GSCSystemService >> doReload [
	self runSudoShellCommand: ('service "', serviceName, '" reload')
]

{ #category : 'starting' }
GSCSystemService >> doRestart [
	self runSudoShellCommand: ('service "', serviceName, '" restart')
]

{ #category : 'starting' }
GSCSystemService >> doStart [
	self runSudoShellCommand: ('service "', serviceName, '" start')
]

{ #category : 'starting' }
GSCSystemService >> doStatus [
	self runSudoShellCommand: ('service "', serviceName, '" status')
]

{ #category : 'starting' }
GSCSystemService >> doStop [
	self runSudoShellCommand: ('service "', serviceName, '" stop')
]

{ #category : 'starting' }
GSCSystemService >> isRunning [
	^ self core runShellIsSuccess: ('systemctl is-active --quiet ', serviceName)

]

{ #category : 'accessing' }
GSCSystemService >> name: aString [
	serviceName := aString
]

{ #category : 'rendering' }
GSCSystemService >> renderBodyOn: html [

"	self renderLabel: 'File path' text: fileReference pathString on: html"
]

{ #category : 'accessing' }
GSCSystemService >> title [
	^ 'Service ', serviceName
]
