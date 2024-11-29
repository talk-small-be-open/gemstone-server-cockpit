Class {
	#name : 'GSCDialogComponent',
	#superclass : 'WAComponent',
	#category : 'GemstoneServerCockpit-View',
	#package : 'GemstoneServerCockpit',
	#tag : 'View'
}

{ #category : 'actions' }
GSCDialogComponent >> cancel [
	self answer: #cancel
]

{ #category : 'actions' }
GSCDialogComponent >> close [
	self answer
]
