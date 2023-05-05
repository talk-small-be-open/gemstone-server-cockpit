Extension { #name : #Collection }

{ #category : #'*GemstoneServerCockpit' }
Collection >> asD [
	^ self asDictionary
]

{ #category : #'*GemstoneServerCockpit' }
Collection >> asOD [
	^ self asOrderedDictionary
]
