Class {
	#name : #GSCGemstoneGems,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCGemstoneGems >> build [

	1 to: self gemsCount do: [ :each |
		self add: GSCGemstoneGem then: [ :gem |
			gem gemIndex: each ]
	].

]

{ #category : #'as yet unclassified' }
GSCGemstoneGems >> gemPorts [
	| start |
	start := self startPort.
	
	^ (1 to: self gemsCount) collect: [ :index |
		start + index - 1 ].
]

{ #category : #'as yet unclassified' }
GSCGemstoneGems >> gemsCount [
	^ (self configAt: 'web:workersCount')
]

{ #category : #'private - initialization' }
GSCGemstoneGems >> initMe [
	super initMe.
	

]

{ #category : #'as yet unclassified' }
GSCGemstoneGems >> startPort [
	"TODO"
	^ 8001 + (self appIndex * 100)
]

{ #category : #accessing }
GSCGemstoneGems >> title [
	^ 'Gems cluster'
]
