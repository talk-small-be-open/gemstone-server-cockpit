Class {
	#name : #GSCConfigurationEditor,
	#superclass : #GSCTool,
	#instVars : [
		'title',
		'editedConfig'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCConfigurationEditor >> checkMe [
	self beNotNeedsAttention.

	editedConfig isFileDifferent ifTrue: [ ^ self beNeedsAttention: 'File differs from config, maybe save it?' ]
]

{ #category : #accessing }
GSCConfigurationEditor >> config: anObject [

	editedConfig := anObject
]

{ #category : #'as yet unclassified' }
GSCConfigurationEditor >> doEditConfig [
	self uiEditText: editedConfig textString then: [ :newText |.
		editedConfig textString: newText.
		editedConfig storeToFile ]
]

{ #category : #'as yet unclassified' }
GSCConfigurationEditor >> doReloadConfigFile [
	editedConfig loadFromFile
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
