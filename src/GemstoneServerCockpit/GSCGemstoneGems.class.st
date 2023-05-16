Class {
	#name : #GSCGemstoneGems,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCGemstoneGems >> build [

	self gemPorts do: [ :each |
		self add: GSCGemstoneGem then: [ :gem |
			gem portNumber: each ]
	].

]

{ #category : #'as yet unclassified' }
GSCGemstoneGems >> gemPorts [
	| start |
	start := self startPort.
	
	^ (1 to: (self configAt: 'web:workersCount')) collect: [ :index |
		start + index - 1 ].
]

{ #category : #'private - initialization' }
GSCGemstoneGems >> initMe [
	super initMe.
	

]

{ #category : #'as yet unclassified' }
GSCGemstoneGems >> startPort [
	"TODO"
	^ 8101
]

{ #category : #accessing }
GSCGemstoneGems >> title [
	^ 'Gems cluster'
]
