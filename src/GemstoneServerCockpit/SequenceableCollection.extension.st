Extension { #name : #SequenceableCollection }

{ #category : #'*GemstoneServerCockpit' }
SequenceableCollection >> joinUsingLf [
	^ self joinUsing: Character lf
]
