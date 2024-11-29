Class {
	#name : 'GSCConfiguration',
	#superclass : 'GSCConfigurationDictionary',
	#instVars : [
		'filePath'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'instance creation' }
GSCConfiguration class >> fromFile: aStringPath [
	^ self new
		loadFromFile: aStringPath;
		yourself
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> createScheme [
	^ self createSchemeDefault: nil
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> createSchemeDefault: aSchemeClass [
	| scheme schemeClass className |
	
	className := self at: #configurationScheme default: [

		"no default given"
		aSchemeClass ifNil: [
			GSCConfigError signal: 'missing configurationScheme in config file' ].
		
		aSchemeClass name asString
	].
	
	schemeClass := Smalltalk at: className asSymbol.
	
	scheme := schemeClass new.
	scheme config: self.
	^ scheme
]

{ #category : 'accessing' }
GSCConfiguration >> filePath [

	^ filePath
]

{ #category : 'accessing' }
GSCConfiguration >> filePath: aString [
	
	filePath := GSCCore instance realPathForFile: aString.
	
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> getDataFromFile: aFilePathString [
	
	| dictionary |
	aFilePathString asFileReference exists ifFalse: [ ^ nil ].

	dictionary := aFilePathString asFileReference readStreamDo: [ :stream |
		STON reader
			on: stream;
			next ].
		
	^ dictionary
]

{ #category : 'accessing' }
GSCConfiguration >> indexFromFilename [
	"03_blablabla.conf -> 3"
	^ (filePath basename copyUpTo: $_ ) asInteger ifNil: [ 0 ]
]

{ #category : 'testing' }
GSCConfiguration >> isFileDifferent [
	| onDisk |
	filePath ifBlank: [ ^ false ].
	
	onDisk := self class fromFile: filePath.
	^ (onDisk isEqualConfig: self) not
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> loadFromFile [
	filePath asFileReference exists ifFalse: [ ^ self ].

	data := self getDataFromFile: filePath
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> loadFromFile: aFilePathString [
	self filePath: aFilePathString.
	
	self loadFromFile
]

{ #category : 'printing' }
GSCConfiguration >> printOn: aStream [
	aStream << 'Configuration: '.
	aStream lf.

	STON writer 
		on: aStream;
		prettyPrint: true;
		newLine: String lf;
		nextPut: data
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> storeToFile [
	
	filePath asFileReference parent ensureCreateDirectory.
	
	filePath asFileReference ensureDelete writeStreamDo: [ :stream |
		STON writer 
			on: stream; 
			prettyPrint: true;
			newLine: String lf;
			nextPut: data ]
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> storeToFile: aPathString [
	self filePath: aPathString.
	self storeToFile.
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> textString [
	^ String streamContents: [ :s |
		STON writer 
			on: s;
			prettyPrint: true;
			newLine: String lf;
			nextPut: data ]
]

{ #category : 'as yet unclassified' }
GSCConfiguration >> textString: aString [
	[ data := STON fromString: aString ] on: STONReaderError do: [ "TODO Show parse error" ]
]
