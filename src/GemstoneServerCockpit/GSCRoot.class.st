Class {
	#name : #GSCRoot,
	#superclass : #GSCTool,
	#instVars : [
		'config'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCRoot >> config [

	^ config
]

{ #category : #accessing }
GSCRoot >> config: anObject [

	config := anObject
]

{ #category : #testing }
GSCRoot >> isRoot [
	^ true
]

{ #category : #accessing }
GSCRoot >> root [
	^ self
]
