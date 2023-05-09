Class {
	#name : #GSCFolder,
	#superclass : #GSCTool,
	#instVars : [
		'name'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCFolder >> name [

	^ name
]

{ #category : #accessing }
GSCFolder >> name: anObject [

	name := anObject
]

{ #category : #accessing }
GSCFolder >> title [
	^ self name
]
