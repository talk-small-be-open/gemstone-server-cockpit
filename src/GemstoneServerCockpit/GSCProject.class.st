Class {
	#name : #GSCProject,
	#superclass : #Object,
	#instVars : [
		'config',
		'folder'
	],
	#category : #GemstoneServerCockpit
}

{ #category : #'as yet unclassified' }
GSCProject class >> config: anObject [
	| version class |
	version := anObject at: #version ifAbsent: ['1'].
	
	class := self getSubclassForVersion: version.
	
	^ class new
		setConfig: anObject;
		yourself
]

{ #category : #'as yet unclassified' }
GSCProject class >> getSubclassForVersion: aString [
	| postfix |
	
	postfix := 'V', aString.
	
	^ self allSubclasses detect: [ :each | each name endsWith: postfix ] ifNone: [ self error: 'Version not found' ]
]

{ #category : #accessing }
GSCProject >> config [
	^ config
]

{ #category : #accessing }
GSCProject >> folder [

	^ folder
]

{ #category : #accessing }
GSCProject >> folder: anObject [

	folder := anObject
]

{ #category : #'as yet unclassified' }
GSCProject >> handleCommandline: aGscCliHandler [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
GSCProject >> putJson: anObject onStream: aStream [
"		STONJSON put: ansibleVars onStreamPretty: s."
	(STON jsonWriter on: aStream)
		prettyPrint: true;
		newLine: String lf;
		nextPut: anObject.

]

{ #category : #initialization }
GSCProject >> setConfig: anObject [
	config := anObject
]
