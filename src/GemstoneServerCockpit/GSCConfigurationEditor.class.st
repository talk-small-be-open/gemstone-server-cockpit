Class {
	#name : #GSCConfigurationEditor,
	#superclass : #GSCTool,
	#instVars : [
		'title',
		'editedConfig'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCConfigurationEditor >> config: anObject [

	editedConfig := anObject
]

{ #category : #'as yet unclassified' }
GSCConfigurationEditor >> doEditConfigFile [
	"TODO"
]

{ #category : #'as yet unclassified' }
GSCConfigurationEditor >> doSaveConfigFile [
	editedConfig storeToFile.
]

{ #category : #rendering }
GSCConfigurationEditor >> renderBodyOn: html [
	self renderLabel: 'File path' text: editedConfig filePath pathString on: html.

	html preformatted: [ 
		html text: editedConfig printString ]
]

{ #category : #accessing }
GSCConfigurationEditor >> title [

	^ title
]

{ #category : #accessing }
GSCConfigurationEditor >> title: anObject [

	title := anObject
]
