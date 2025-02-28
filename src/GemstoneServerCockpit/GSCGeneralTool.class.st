Class {
	#name : 'GSCGeneralTool',
	#superclass : 'GSCTool',
	#instVars : [
		'checkMeBlock',
		'actionBlock',
		'title'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'accessing' }
GSCGeneralTool >> actionBlock [

	^ actionBlock
]

{ #category : 'accessing' }
GSCGeneralTool >> actionBlock: anObject [

	actionBlock := anObject
]

{ #category : 'as yet unclassified' }
GSCGeneralTool >> checkMe [
	self beNotNeedsAttention.
	
	checkMeBlock ifNotNil: [ checkMeBlock cull: self ]
]

{ #category : 'accessing' }
GSCGeneralTool >> checkMeBlock [

	^ checkMeBlock
]

{ #category : 'accessing' }
GSCGeneralTool >> checkMeBlock: anObject [

	checkMeBlock := anObject
]

{ #category : 'as yet unclassified' }
GSCGeneralTool >> doAction [
	actionBlock ifNotNil: [ actionBlock cull: self ]
]

{ #category : 'accessing' }
GSCGeneralTool >> title [

	^ title ifBlank: [ 'unnamed tool' ]
]

{ #category : 'accessing' }
GSCGeneralTool >> title: anObject [

	title := anObject
]
