Class {
	#name : #GSCApplication,
	#superclass : #GSCTool,
	#instVars : [
		'config'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCApplication >> application [
	^ self
]

{ #category : #accessing }
GSCApplication >> config [

	^ config
]

{ #category : #accessing }
GSCApplication >> config: anObject [

	config := anObject
]

{ #category : #'as yet unclassified' }
GSCApplication >> doSaveConfigFile [
	config storeToFile.
]

{ #category : #'as yet unclassified' }
GSCApplication >> longName [
	^ 'TODO TODO TODO'
]

{ #category : #rendering }
GSCApplication >> renderBodyOn: html [
	html preformatted: [ 
		html text: config printString ]
]

{ #category : #'as yet unclassified' }
GSCApplication >> shortCode [
	^ self configAt: 'project:shortCode'
]
