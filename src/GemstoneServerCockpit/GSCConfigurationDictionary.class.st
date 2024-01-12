Class {
	#name : #GSCConfigurationDictionary,
	#superclass : #Object,
	#instVars : [
		'data'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCConfigurationDictionary class >> commentPrefix [
	^ '__'
]

{ #category : #'instance creation' }
GSCConfigurationDictionary class >> fromDictionary: aDictionary [
	^ self new
		data: aDictionary;
		yourself
]

{ #category : #arithmetic }
GSCConfigurationDictionary >> / aString [
	^ self at: aString
]

{ #category : #converting }
GSCConfigurationDictionary >> asDictionary [
	^ self dataCopy
]

{ #category : #arithmetic }
GSCConfigurationDictionary >> at: aPathlikeStructure [
	| parts dict |
	parts := self getKeySequence: aPathlikeStructure.
	
	dict := self getNestedDictionary: parts allButLast ifAbsent: [ ^ nil ].
	
	^ self transformForReadout: (dict at: (parts last asString) ifAbsent: [ nil ])
]

{ #category : #arithmetic }
GSCConfigurationDictionary >> at: aSymbol default: aBlock [
	^ (self at: aSymbol) ifNil: [ 
		self at: aSymbol put: aBlock value ]
]

{ #category : #arithmetic }
GSCConfigurationDictionary >> at: aSymbol ifAbsent: aBlock [
	^ (self at: aSymbol) ifNil: aBlock
]

{ #category : #arithmetic }
GSCConfigurationDictionary >> at: aPathlikeStructure put: aValue [
	| parts dict |
	parts := self getKeySequence: aPathlikeStructure.
	
	dict := self getNestedDictionary: parts allButLast.
	
	^ self transformForReadout: (dict at: (parts last asString) put: aValue)
]

{ #category : #'as yet unclassified' }
GSCConfigurationDictionary >> copyWith: another [
	^ self copy overwriteWith: another
]

{ #category : #accessing }
GSCConfigurationDictionary >> data: aDictionary [
	data := self dictionaryClass new.
	self recurseCopyDataFrom: aDictionary to: data
]

{ #category : #copying }
GSCConfigurationDictionary >> dataCopy [
	| newDict |

	newDict := self dictionaryClass new.
	self recurseCopyDataFrom: data to: newDict.

	^ newDict
]

{ #category : #enumerating }
GSCConfigurationDictionary >> dataDo: aBlockWithKeyAndValue [
	"Official method to enumerate through real data, without the comments"
	self keysAndValuesDo: [ :key :value |
		(self isCommentKey: key) ifFalse: [
			aBlockWithKeyAndValue value: key value: value ] ]
]

{ #category : #accessing }
GSCConfigurationDictionary >> dictionaryClass [
	"keep it Dictionary, since then STON is cleaner, instead of IdentityDictionary.
	TODO: Maybe OrderedDictionary would work with STON?"
	^ Dictionary
]

{ #category : #accessing }
GSCConfigurationDictionary >> entriesCount [
	| counter |
	counter := 0.
	self entriesDo: [ :key :value | counter := counter + 1 ].
	^ counter
]

{ #category : #enumerating }
GSCConfigurationDictionary >> entriesDo: aTwoArgBlock [
	"keyPath value"
	self nodesDo: [ :keyPath :value |
		value isDictionary ifFalse: [ aTwoArgBlock value: keyPath value: value ]
	]
]

{ #category : #arithmetic }
GSCConfigurationDictionary >> getKeySequence: aPathlikeStructure [

	aPathlikeStructure isString ifTrue: [
		^ aPathlikeStructure asString findTokens: '.:'
	].

	aPathlikeStructure isCollection ifTrue: [
		^ aPathlikeStructure collect: [ :each | each asString ]
	].
	
	self error: 'Wrong format of path'

]

{ #category : #arithmetic }
GSCConfigurationDictionary >> getNestedDictionary: aKeysCollection [
	^ self getNestedDictionary: aKeysCollection ifAbsent: nil
]

{ #category : #arithmetic }
GSCConfigurationDictionary >> getNestedDictionary: aKeysCollection ifAbsent: aBlock [
	| current |
	
	"Get the inner dictionary object at pathlike location aKeysCollection"
	
	current := data.
	aKeysCollection do: [ :each |
		| next |
		
		current isDictionary ifFalse: [ self error: 'Can not access non-dictionary config node' ].
		
		aBlock ifNotNil: [ current at: each asString ifAbsent: [ ^ aBlock value ] ].
		
		next := current at: each asString ifAbsentPut: [ self dictionaryClass new ].
		current := next.
	].
	
	^ current
]

{ #category : #initialization }
GSCConfigurationDictionary >> initialize [
	super initialize.
	
	data := self dictionaryClass new
]

{ #category : #testing }
GSCConfigurationDictionary >> isCommentKey: aString [
	^ aString beginsWith: self class commentPrefix
]

{ #category : #testing }
GSCConfigurationDictionary >> isEqualConfig: anotherConfig [

	self entriesCount = anotherConfig entriesCount ifFalse: [ ^ false ].

	self entriesDo: [ :keyPath :value |
		((anotherConfig at: keyPath) = value) ifFalse: [ ^ false ].
	].

	^ true
]

{ #category : #enumerating }
GSCConfigurationDictionary >> keysAndValuesDo: aBlock [
	data keys sorted do: [ :each |
		aBlock value: each value: (self at: each) ]
]

{ #category : #enumerating }
GSCConfigurationDictionary >> nodesDo: aTwoArgBlock [
	self recurseIn: data path: OrderedCollection new do: aTwoArgBlock
]

{ #category : #'as yet unclassified' }
GSCConfigurationDictionary >> overwriteWith: another [
	another entriesDo: [ :keyPath :value |
		self at: keyPath put: value
	]
]

{ #category : #copying }
GSCConfigurationDictionary >> postCopy [
	| originalData |
	
	super postCopy.
	
	"data := data deepCopy."
"	self nodesDo: [ :key :value |
		self at: key put: value copy
	]."

	originalData := data.
	data := self dictionaryClass new.
	self recurseCopyDataFrom: originalData to: data.
]

{ #category : #'as yet unclassified' }
GSCConfigurationDictionary >> presetFrom: another [
	another entriesDo: [ :keyPath :value |
"		value ifNotBlank: ["
		self at: keyPath default: value
	]
]

{ #category : #enumerating }
GSCConfigurationDictionary >> recurseCopyDataFrom: aSourceDictionary to: aTargetDictionary [
	"Copy the nested dictionary structure"

	aSourceDictionary keysAndValuesDo: [ :key :value |
		value isDictionary
			ifTrue: [
				| newDict |
				newDict := self dictionaryClass new.
				aTargetDictionary at: key put: newDict.
				self recurseCopyDataFrom: value to: newDict.
			]
			ifFalse: [
				aTargetDictionary at: key put: value copy
			]
	]
]

{ #category : #enumerating }
GSCConfigurationDictionary >> recurseIn: aDictionary path: aKeysCollection do: aTwoArgBlock [

	"aTwoArgBlock takes keyPathInStructure dictionaryAtThisPath"
	
	aDictionary keysAndValuesDo: [ :key :value |
"		(self isCommentKey: key) ifFalse: ["
			| newPath |
			
			newPath := aKeysCollection copyWith: key.

			aTwoArgBlock value: newPath value: value.
			
			value isDictionary ifTrue: [
				self recurseIn: value path: newPath do: aTwoArgBlock ].
"		]"
	]
]

{ #category : #'as yet unclassified' }
GSCConfigurationDictionary >> transformForReadout: anObject [
	anObject isDictionary ifTrue: [ ^ GSCConfigurationDictionary fromDictionary: anObject ].
	
	^ anObject
]

{ #category : #accessing }
GSCConfigurationDictionary >> values [
	^ data values
]
