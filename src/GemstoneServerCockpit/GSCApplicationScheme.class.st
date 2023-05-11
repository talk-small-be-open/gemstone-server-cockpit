Class {
	#name : #GSCApplicationScheme,
	#superclass : #GSCSchemeBase,
	#instVars : [
		'config'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCApplicationScheme >> buildApplicationToolInto: aRootTool [
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
