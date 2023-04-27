Class {
	#name : #GSCConfiguration,
	#superclass : #Object,
	#instVars : [
		'fileReference',
		'data'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'instance creation' }
GSCConfiguration class >> fromDictionary: aDictionary [
	^ self new
		data: aDictionary;
		yourself
]

{ #category : #'instance creation' }
GSCConfiguration class >> fromFile: aStringPath [
	^ self new
		loadFromFile: aStringPath;
		yourself
]

{ #category : #arithmetic }
GSCConfiguration >> / aSymbol [
	^ self at: aSymbol
]

{ #category : #arithmetic }
GSCConfiguration >> at: aSymbol [
	| parts dict |
	parts := self getKeySequence: aSymbol.
	
	dict := self getNestedDictionary: parts allButLast.
	
	^ dict at: (parts last) ifAbsentPut: [ nil ]
]

{ #category : #arithmetic }
GSCConfiguration >> at: aSymbol default: aBlock [
	^ (self at: aSymbol) ifNil: [ 
		self at: aSymbol put: aBlock value ]
]

{ #category : #arithmetic }
GSCConfiguration >> at: aSymbol ifAbsent: aBlock [
	^ (self at: aSymbol) ifNil: aBlock
]

{ #category : #arithmetic }
GSCConfiguration >> at: aSymbol put: aValue [
	| parts dict |
	parts := self getKeySequence: aSymbol.
	
	dict := self getNestedDictionary: parts allButLast.
	
	^ dict at: (parts last) put: aValue
]

{ #category : #accessing }
GSCConfiguration >> data: aDictionary [
	data := self dictionaryClass newFrom: aDictionary
]

{ #category : #accessing }
GSCConfiguration >> dictionaryClass [
	"keep it Dictionary, since then STON is cleaner, instead of IdentityDictionary"
	^ Dictionary
]

{ #category : #enumerating }
GSCConfiguration >> entriesDo: aTwoArgBlock [
	"keyPath value"
	self nodesDo: [ :keyPath :value |
		value isDictionary ifFalse: [ aTwoArgBlock value: keyPath value: value ]
	]
]

{ #category : #arithmetic }
GSCConfiguration >> getKeySequence: aSymbolOrString [
	^ aSymbolOrString asSymbol findTokens: '.:'

]

{ #category : #arithmetic }
GSCConfiguration >> getNestedDictionary: aKeysCollection [
	| current |
	
	current := data.
	aKeysCollection do: [ :each |
		| next |
		
		current isDictionary ifFalse: [ self error: 'Can not access non-dictionary config node' ].
		
		next := current at: each asSymbol ifAbsentPut: [ self dictionaryClass new ].
		current := next.
	].
	
	^ current
]

{ #category : #initialization }
GSCConfiguration >> initialize [
	super initialize.
	
	data := self dictionaryClass new
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> loadFromFile: aFilePathString [
	fileReference := aFilePathString asFileReference.
	
	fileReference exists ifFalse: [ ^ self ].

	data := fileReference readStreamDo: [ :stream | 
		STON reader
			on: stream;
			next ]
]

{ #category : #enumerating }
GSCConfiguration >> nodesDo: aTwoArgBlock [
	self recurseIn: data path: OrderedCollection new do: aTwoArgBlock
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> presetFrom: another [
	another entriesDo: [ :keyPath :value |
		value ifNotBlank: [  ]
	]
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

{ #category : #enumerating }
GSCConfiguration >> recurseIn: aDictionary path: aKeysCollection do: aTwoArgBlock [

	"aTwoArgBlock takes keyPathInStructure dictionaryAtThisPath"
	
	aDictionary keysAndValuesDo: [ :key :value |
		| newPath |
		newPath := aKeysCollection copyWith: key.

		aTwoArgBlock value: newPath value: value.
		
		value isDictionary ifTrue: [
			self recurseIn: value path: newPath do: aTwoArgBlock ].

	]
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
	self storeToFile: fileReference pathString
]

{ #category : #'as yet unclassified' }
GSCConfiguration >> storeToFile: aPathString [
	fileReference := aPathString asFileReference.
	
	
	fileReference ensureDelete writeStreamDo: [ :stream |
		STON writer 
			on: stream; 
			prettyPrint: true;
			newLine: String lf;
			nextPut: data ]
]
