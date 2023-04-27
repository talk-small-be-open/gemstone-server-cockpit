Class {
	#name : #GSCApplicationScheme,
	#superclass : #Object,
	#instVars : [
		'config'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCApplicationScheme >> buildApplicationToolInto: aRootTool [
	self subclassResponsibility
]

{ #category : #building }
GSCApplicationScheme >> buildDefaultConfiguration [
	self subclassResponsibility
]

{ #category : #building }
GSCApplicationScheme >> buildEmptyConfiguration [
	self subclassResponsibility
]

{ #category : #accessing }
GSCApplicationScheme >> config [

	^ config
]

{ #category : #accessing }
GSCApplicationScheme >> config: anObject [

	config := anObject.
	
	self ensureDefaultConfig
]

{ #category : #accessing }
GSCApplicationScheme >> ensureDefaultConfig [
	"subclasses"
]
