Class {
	#name : 'GSCTextViewer',
	#superclass : 'GSCDialogComponent',
	#instVars : [
		'content'
	],
	#category : 'GemstoneServerCockpit-View',
	#package : 'GemstoneServerCockpit',
	#tag : 'View'
}

{ #category : 'accessing' }
GSCTextViewer class >> content: aString [
	^ self new
		content: aString;
		yourself
]

{ #category : 'accessing' }
GSCTextViewer >> content [

	^ content
]

{ #category : 'accessing' }
GSCTextViewer >> content: anObject [

	content := anObject
]

{ #category : 'rendering' }
GSCTextViewer >> renderContentOn: html [
	html anchorButton
		callback: [ self cancel ];
		with: 'Close'.
		
	html preformatted: content.

]
