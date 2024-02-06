Class {
	#name : #GSCApplicationScheme,
	#superclass : #GSCSchemeBase,
	#category : #'GemstoneServerCockpit-Scheme'
}

{ #category : #building }
GSCApplicationScheme >> buildApplicationToolInto: aRootTool [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
GSCApplicationScheme >> templateGemMonitConfig [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
GSCApplicationScheme >> templateHaproxySite [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
GSCApplicationScheme >> templateNetldiMonitConfig [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
GSCApplicationScheme >> templateNginxSiteVhost [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
GSCApplicationScheme >> templateStoneMonitConfig [
	self subclassResponsibility
]
