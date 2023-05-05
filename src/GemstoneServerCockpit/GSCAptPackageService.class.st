Class {
	#name : #GSCAptPackageService,
	#superclass : #GSCTool,
	#instVars : [
		'packageName'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCAptPackageService >> checkMe [
	self beNotNeedsAttention.
	
	self isInstalled ifFalse: [ ^ self beNeedsAttention: 'Package is not installed' ].
	

]

{ #category : #'as yet unclassified' }
GSCAptPackageService >> doInstall [
	self runSudoShellCommand: ('apt install --yes ', packageName)
]

{ #category : #testing }
GSCAptPackageService >> isInstalled [
	^ GSCCore instance runShellIsSuccess: ('dpkg-query --status ', packageName)

]

{ #category : #accessing }
GSCAptPackageService >> packageName [

	^ packageName
]

{ #category : #accessing }
GSCAptPackageService >> packageName: anObject [

	packageName := anObject
]
