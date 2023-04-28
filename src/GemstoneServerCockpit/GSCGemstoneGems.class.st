Class {
	#name : #GSCGemstoneGems,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCGemstoneGems >> build [

	(self configAt: 'gemstone:gemPorts') do: [ :port |
		self add: GSCGemstoneGem then: [ :gem |
			gem portNumber: port ]
	].

]

{ #category : #'private - initialization' }
GSCGemstoneGems >> initMe [
	super initMe.
	

]
