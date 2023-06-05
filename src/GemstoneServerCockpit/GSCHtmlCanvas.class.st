Class {
	#name : #GSCHtmlCanvas,
	#superclass : #WAHtmlCanvas,
	#category : #'GemstoneServerCockpit-View'
}

{ #category : #'as yet unclassified' }
GSCHtmlCanvas >> anchorButton [
	^ self anchor
		class: 'anchorButton';
		yourself
]
