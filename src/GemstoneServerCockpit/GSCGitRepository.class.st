Class {
	#name : #GSCGitRepository,
	#superclass : #GSCTool,
	#instVars : [
		'url',
		'folderPath'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCGitRepository >> checkMe [
	self beNotNeedsAttention.
	
	self folderPath asFileReference exists ifFalse: [ ^ self beNeedsAttention: 'git repo does not exist' ].

]

{ #category : #'as yet unclassified' }
GSCGitRepository >> doCloneFromGitRepo [
	| path |
	path := self folderPath.
	
	self runSudoShellCommand: ('mkdir -p ', path, ' && chown ', (self configAt: 'server:username'), ' ', path) then: [
		self runShellCommand: ('git clone ', self url, ' ', path) ]
]

{ #category : #accessing }
GSCGitRepository >> folderPath [

	^ folderPath
]

{ #category : #accessing }
GSCGitRepository >> folderPath: anObject [

	folderPath := anObject
]

{ #category : #accessing }
GSCGitRepository >> url [

	^ url
]

{ #category : #accessing }
GSCGitRepository >> url: anObject [

	url := anObject
]
