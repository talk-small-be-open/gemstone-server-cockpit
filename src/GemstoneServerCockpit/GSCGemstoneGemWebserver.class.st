Class {
	#name : 'GSCGemstoneGemWebserver',
	#superclass : 'GSCTool',
	#category : 'GemstoneServerCockpit-Deprecated',
	#package : 'GemstoneServerCockpit',
	#tag : 'Deprecated'
}

{ #category : 'as yet unclassified' }
GSCGemstoneGemWebserver >> checkMe [
	self beNotNeedsAttention.

	"TODO get: GemServer gemServerNamed: serverName"
	
	"self beNeedsAttention: 'GemServer not registered'"
]

{ #category : 'accessing' }
GSCGemstoneGemWebserver >> gemTool [

	^ self parent
]

{ #category : 'accessing' }
GSCGemstoneGemWebserver >> title [
	^ 'Seaside internal Zinc webserver'
]
