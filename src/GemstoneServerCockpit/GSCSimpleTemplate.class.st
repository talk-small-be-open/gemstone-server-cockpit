Class {
	#name : #GSCSimpleTemplate,
	#superclass : #GSCTextTemplate,
	#instVars : [
		'source',
		'replacements'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCSimpleTemplate >> initialize [
	super initialize.
	
	replacements := Dictionary new
]

{ #category : #accessing }
GSCSimpleTemplate >> replace: aString with: anotherString [
	replacements at: aString put: anotherString
]

{ #category : #accessing }
GSCSimpleTemplate >> source [

	^ source
]

{ #category : #accessing }
GSCSimpleTemplate >> source: anObject [

	source := anObject
]
