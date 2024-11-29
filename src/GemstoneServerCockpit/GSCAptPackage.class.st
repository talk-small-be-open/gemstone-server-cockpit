Class {
	#name : 'GSCAptPackage',
	#superclass : 'GSCTool',
	#instVars : [
		'packageName'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'as yet unclassified' }
GSCAptPackage >> checkMe [
	self beNotNeedsAttention.
	
	self isInstalled ifFalse: [ ^ self beNeedsAttention: 'Package is not installed' ].
	

]

{ #category : 'as yet unclassified' }
GSCAptPackage >> doInstall [
	self runSudoShellCommand: ('apt --quiet --yes install ', packageName)
]

{ #category : 'testing' }
GSCAptPackage >> isInstalled [
	^ self core runShellIsSuccess: ('dpkg-query --status ', packageName)

]

{ #category : 'accessing' }
GSCAptPackage >> packageName [

	^ packageName
]

{ #category : 'accessing' }
GSCAptPackage >> packageName: anObject [

	packageName := anObject
]

{ #category : 'accessing' }
GSCAptPackage >> title [
	^ 'APT ', packageName
]
