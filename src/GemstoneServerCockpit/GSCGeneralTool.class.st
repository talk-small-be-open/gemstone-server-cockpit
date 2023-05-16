Class {
	#name : #GSCGeneralTool,
	#superclass : #GSCTool,
	#instVars : [
		'checkMeBlock',
		'actionBlock',
		'title'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCGeneralTool >> actionBlock [

	^ actionBlock
]

{ #category : #accessing }
GSCGeneralTool >> actionBlock: anObject [

	actionBlock := anObject
]

{ #category : #'as yet unclassified' }
GSCGeneralTool >> checkMe [
	self beNotNeedsAttention.
	
	checkMeBlock ifNotNil: [ checkMeBlock value ]
]

{ #category : #accessing }
GSCGeneralTool >> checkMeBlock [

	^ checkMeBlock
]

{ #category : #accessing }
GSCGeneralTool >> checkMeBlock: anObject [

	checkMeBlock := anObject
]

{ #category : #'as yet unclassified' }
GSCGeneralTool >> doAction [
	actionBlock ifNotNil: [ actionBlock value ]
]

{ #category : #accessing }
GSCGeneralTool >> title [

	^ title
]

{ #category : #accessing }
GSCGeneralTool >> title: anObject [

	title := anObject
]
