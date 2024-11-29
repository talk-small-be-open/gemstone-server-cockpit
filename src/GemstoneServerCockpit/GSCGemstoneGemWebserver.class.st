Class {
	#name : 'GSCGemstoneGemWebserver',
	#superclass : 'GSCTool',
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'as yet unclassified' }
GSCGemstoneGemWebserver >> checkMe [
	self beNotNeedsAttention.

	"TODO get: GemServer gemServerNamed: serverName"
	
	"self beNeedsAttention: 'GemServer not registered'"
]

{ #category : 'as yet unclassified' }
GSCGemstoneGemWebserver >> doRegisterZincWebserver [
	"Register Servers in tODE"
	| p i |
	p := self gemTool portNumber asString.
	i := self gemTool gemIndex asString.
	self runTodeCommand: ('/home/seaside/gemServer --register=seaside', i, ' --type=zinc --port=', p) stone: self gemTool stoneName
]

{ #category : 'accessing' }
GSCGemstoneGemWebserver >> gemTool [

	^ self parent
]

{ #category : 'accessing' }
GSCGemstoneGemWebserver >> title [
	^ 'Seaside internal Zinc webserver'
]
