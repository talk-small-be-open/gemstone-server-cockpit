Class {
	#name : #GSCSchemeBase,
	#superclass : #Object,
	#instVars : [
		'config'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCSchemeBase >> buildDefaultConfiguration [
	^ self defaultConfigurationBuilder asGscConfiguration
]

{ #category : #accessing }
GSCSchemeBase >> config [

	^ config
]

{ #category : #accessing }
GSCSchemeBase >> config: anObject [

	config := anObject.
	
	self ensureDefaultConfig
]

{ #category : #'as yet unclassified' }
GSCSchemeBase >> defaultConfigurationBuilder [
	| builder |
	
	builder := GSCEasyConfigurationBuilder new.

	builder applicationScheme: self className.
	
	^ builder
]

{ #category : #accessing }
GSCSchemeBase >> ensureDefaultConfig [
	
	config presetFrom: self buildDefaultConfiguration
	
	"config at: 'gems:count' default: [ 3 ]"
]
