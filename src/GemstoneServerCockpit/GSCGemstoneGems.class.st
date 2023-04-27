Class {
	#name : #GSCGemstoneGems,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCGemstoneGems >> build [

	1 to: (self configAt: 'gems:count') do: [ :index |
		self add: GSCGemstoneGem
	].

]

{ #category : #'private - initialization' }
GSCGemstoneGems >> initMe [
	super initMe.
	

]
