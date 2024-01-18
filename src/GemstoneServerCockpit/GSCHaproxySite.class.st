Class {
	#name : #GSCHaproxySite,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCHaproxySite >> gemPorts [
	| gemsTool |
	gemsTool := self appFindTool: GSCGemstoneGems.
	
	^ gemsTool gemPorts
]

{ #category : #'as yet unclassified' }
GSCHaproxySite >> haproxyConfigTemplate [
	^ self scheme templateHaproxySite
		tool: self;
		yourself
]

{ #category : #rendering }
GSCHaproxySite >> renderBodyOn: html [
	html paragraph: 'site config file will be included in master config file of HAproxy.'
]

{ #category : #accessing }
GSCHaproxySite >> title [
	^ 'HAproxy site'
]
