Class {
	#name : #GSCSttTemplate,
	#superclass : #GSCTextTemplate,
	#instVars : [
		'mclSmalltalkTemplate',
		'tool'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'instance creation' }
GSCSttTemplate class >> tool: aGscTool sttString: aString [
	^ self new
		tool: aGscTool;
		sttString: aString;
		yourself
]

{ #category : #accessing }
GSCSttTemplate >> contentString [
	| me |
	me := GSCSmalltalkTemplateDataGateway tool: tool.

	^ mclSmalltalkTemplate evaluateFor: me
]

{ #category : #'as yet unclassified' }
GSCSttTemplate >> sttString: aString [
	mclSmalltalkTemplate := MCLSmalltalkTemplate on: aString
]

{ #category : #accessing }
GSCSttTemplate >> tool [

	^ tool
]

{ #category : #accessing }
GSCSttTemplate >> tool: anObject [

	tool := anObject
]
