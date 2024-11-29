"
Specialized data dictionary for the root element, which is given into the report
"
Class {
	#name : 'GSCSmalltalkTemplateDataGateway',
	#superclass : 'MCLSmalltalkTemplateDictionary',
	#instVars : [
		'tool'
	],
	#category : 'GemstoneServerCockpit-Misc',
	#package : 'GemstoneServerCockpit',
	#tag : 'Misc'
}

{ #category : 'accessing' }
GSCSmalltalkTemplateDataGateway class >> tool: aGscTool [
	^ self new
		tool: aGscTool;
		yourself
]

{ #category : 'initialization' }
GSCSmalltalkTemplateDataGateway >> initialize [
	super initialize.

]

{ #category : 'accessing' }
GSCSmalltalkTemplateDataGateway >> tool: anObject [

	tool := anObject
]
