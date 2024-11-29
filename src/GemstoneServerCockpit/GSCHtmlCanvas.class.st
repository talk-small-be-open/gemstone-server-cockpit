Class {
	#name : 'GSCHtmlCanvas',
	#superclass : 'WAHtmlCanvas',
	#category : 'GemstoneServerCockpit-View',
	#package : 'GemstoneServerCockpit',
	#tag : 'View'
}

{ #category : 'as yet unclassified' }
GSCHtmlCanvas >> anchorButton [
	^ self anchor
		class: 'anchorButton';
		yourself
]
