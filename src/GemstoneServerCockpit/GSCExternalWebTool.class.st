Class {
	#name : #GSCExternalWebTool,
	#superclass : #GSCTool,
	#instVars : [
		'url'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #rendering }
GSCExternalWebTool >> renderBodyOn: html [
	html iframe
		url: url
]

{ #category : #accessing }
GSCExternalWebTool >> url [

	^ url
]

{ #category : #accessing }
GSCExternalWebTool >> url: anObject [

	url := anObject
]
