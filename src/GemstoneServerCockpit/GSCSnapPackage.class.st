Class {
	#name : 'GSCSnapPackage',
	#superclass : 'GSCTool',
	#instVars : [
		'packageName'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'as yet unclassified' }
GSCSnapPackage >> checkMe [
	self beNotNeedsAttention.
	
	self isInstalled ifFalse: [ ^ self beNeedsAttention: 'Package is not installed' ].
	

]

{ #category : 'as yet unclassified' }
GSCSnapPackage >> doInstall [
	self runSudoShellCommand: ('snap install --classic ', packageName)
]

{ #category : 'testing' }
GSCSnapPackage >> isInstalled [
	^ self core runShellIsSuccess: ('snap list ', packageName)

]

{ #category : 'accessing' }
GSCSnapPackage >> packageName [

	^ packageName
]

{ #category : 'accessing' }
GSCSnapPackage >> packageName: anObject [

	packageName := anObject
]

{ #category : 'as yet unclassified' }
GSCSnapPackage >> title [
	^ 'SNAP ', packageName
]
