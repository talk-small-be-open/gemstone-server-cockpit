Class {
	#name : #GSCConfiguration,
	#superclass : #GSCConfigurationDictionary,
	#instVars : [
		'filePath'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'instance creation' }
GSCConfiguration class >> fromFile: aStringPath [
	^ self new
		loadFromFile: aStringPath;
		yourself
]

{ #category : #accessing }
GSCConfiguration >> filePath [

	^ filePath
]

{ #category : #accessing }
GSCConfiguration >> filePath: aString [
	
	filePath := GSCCore instance realPathForFile: aString.
	
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> loadFromFile: aFilePathString [
	self filePath: aFilePathString.
	
	filePath asFileReference exists ifFalse: [ ^ self ].

	data := filePath asFileReference readStreamDo: [ :stream | 
		STON reader
			on: stream;
			next ]
]

{ #category : #printing }
GSCConfiguration >> printOn: aStream [
	aStream << 'Configuration: '.
	aStream lf.

	STON writer 
		on: aStream;
		prettyPrint: true;
		newLine: String lf;
		nextPut: data
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> schemeClass [
	"TBD"
"	^ GSCWebApplicationSchemeV1"
	| className |
	className := self at: #applicationScheme ifAbsent: [ 'GSCWebApplicationSchemeV1' ].
	
	Smalltalk at: className asSymbol.
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> storeToFile [
	
	filePath asFileReference parent ensureCreateDirectory.
	
	filePath asFileReference ensureDelete writeStreamDo: [ :stream |
		STON writer 
			on: stream; 
			prettyPrint: true;
			newLine: String lf;
			nextPut: data ]
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> storeToFile: aPathString [
	self filePath: aPathString.
	self storeToFile.
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> textString [
	^ String streamContents: [ :s |
		STON writer 
			on: s;
			prettyPrint: true;
			newLine: String lf;
			nextPut: data ]
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> textString: aString [
	data := STON fromString: aString
]
