Class {
	#name : 'GSCSimpleTemplate',
	#superclass : 'GSCTextTemplate',
	#instVars : [
		'source',
		'replacements'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'accessing' }
GSCSimpleTemplate class >> source: aString [
	^ self new
		source: aString;
		yourself
]

{ #category : 'accessing' }
GSCSimpleTemplate >> contentString [
	| out |
	out := source.
	
	replacements keysAndValuesDo: [ :search :replace |
		out := out copyReplaceAll: search with: replace
	].
	
	^ out
]

{ #category : 'accessing' }
GSCSimpleTemplate >> initialize [
	super initialize.
	
	replacements := Dictionary new
]

{ #category : 'accessing' }
GSCSimpleTemplate >> replace: aString with: anotherString [
	replacements at: aString put: anotherString
]

{ #category : 'accessing' }
GSCSimpleTemplate >> source [

	^ source
]

{ #category : 'accessing' }
GSCSimpleTemplate >> source: anObject [

	source := anObject
]
