Class {
	#name : #GSCTextEditor,
	#superclass : #GSCDialogComponent,
	#instVars : [
		'content',
		'originalContent'
	],
	#category : #'GemstoneServerCockpit-View'
}

{ #category : #accessing }
GSCTextEditor class >> content: aString [
	^ self new
		originalContent: aString;
		yourself
]

{ #category : #accessing }
GSCTextEditor >> content [

	^ content
]

{ #category : #accessing }
GSCTextEditor >> content: anObject [

	content := anObject
]

{ #category : #accessing }
GSCTextEditor >> originalContent: anObject [

	originalContent := anObject.
	self content: anObject
]

{ #category : #rendering }
GSCTextEditor >> renderContentOn: html [
	html form: [ 
		html textArea
			style: 'width: 100%; height: 70em;';
			on: #content of: self.
		html submitButton
			callback: [ self save ];
			with: 'Save'
	].

	html anchorButton
		callback: [ self cancel ];
		with: 'Cancel'.
		
	html heading level2; with: 'Original'.
	html preformatted: originalContent.

]

{ #category : #actions }
GSCTextEditor >> save [
	self close
]
