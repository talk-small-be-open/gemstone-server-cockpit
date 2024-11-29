Class {
	#name : 'GSCFolder',
	#superclass : 'GSCTool',
	#instVars : [
		'name'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'accessing' }
GSCFolder >> name [

	^ name
]

{ #category : 'accessing' }
GSCFolder >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
GSCFolder >> title [
	^ self name
]
