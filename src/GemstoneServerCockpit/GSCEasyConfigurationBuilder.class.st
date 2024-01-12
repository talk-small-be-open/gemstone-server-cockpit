"
Helper for convenience. Builds a dictionary configuration structure by dynamically storing values, which are set by non-existent setter methods. Uses DNU.

Example:
	
	me thisValue: 'one'.
	me thatOtherValue: 'two'.
	me whateverElseYouNeedInYourConfigDictionary: 123.
"
Class {
	#name : #GSCEasyConfigurationBuilder,
	#superclass : #Object,
	#instVars : [
		'values'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCEasyConfigurationBuilder >> __ [
	^ self comment
]

{ #category : #converting }
GSCEasyConfigurationBuilder >> asGscConfiguration [
	^ GSCConfiguration fromDictionary: self asNestedDictionary
]

{ #category : #converting }
GSCEasyConfigurationBuilder >> asJsonString [
	^ String streamContents: [ :s |
		(STON jsonWriter on: s)
			prettyPrint: true;
			newLine: String lf;
			nextPut: self asNestedDictionary ]
]

{ #category : #converting }
GSCEasyConfigurationBuilder >> asNestedDictionary [
	^ (Dictionary newFrom: values) collect: [ :each |
		(each isKindOf: GSCEasyConfigurationBuilder)
			ifTrue: [ each asNestedDictionary ]
			ifFalse: [ each ]
	]
]

{ #category : #accessing }
GSCEasyConfigurationBuilder >> at: aKey [
	^ values at: aKey asSymbol ifAbsentPut: [ GSCEasyConfigurationBuilder new ]
]

{ #category : #accessing }
GSCEasyConfigurationBuilder >> at: aKey ifAbsent: aBlock [
	^ values at: aKey asSymbol ifAbsent: aBlock
]

{ #category : #accessing }
GSCEasyConfigurationBuilder >> at: aKey put: aValue [
	^ values at: aKey asSymbol put: aValue
]

{ #category : #initialization }
GSCEasyConfigurationBuilder >> clear [
	values := IdentityDictionary new
]

{ #category : #accessing }
GSCEasyConfigurationBuilder >> comment [
	^ self at: '__comment'
]

{ #category : #accessing }
GSCEasyConfigurationBuilder >> comment: aString [
	^ self at: '__comment' put: aString
]

{ #category : #'reflective operations' }
GSCEasyConfigurationBuilder >> doesNotUnderstand: aMessage [
	| sel |
	sel := aMessage selector.
	
	sel isUnary ifTrue: [ ^ self at: sel ].
	sel numArgs = 1 ifTrue: [
		| key |
		key := sel allButLast asSymbol.
		^ self at: key put: aMessage argument ].
	
	super doesNotUnderstand: aMessage
]

{ #category : #initialization }
GSCEasyConfigurationBuilder >> initialize [
	super initialize.
	self clear
]
