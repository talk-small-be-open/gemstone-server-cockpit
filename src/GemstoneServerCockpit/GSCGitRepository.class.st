Class {
	#name : 'GSCGitRepository',
	#superclass : 'GSCTool',
	#instVars : [
		'url',
		'folderPath',
		'branch'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'accessing' }
GSCGitRepository >> branch [

	^ branch ifBlank: [ 'master' ]
]

{ #category : 'accessing' }
GSCGitRepository >> branch: anObject [

	branch := anObject
]

{ #category : 'as yet unclassified' }
GSCGitRepository >> checkMe [
	self beNotNeedsAttention.
	
	(self core dirExists: (self folderPath / '.git') ) ifFalse: [ ^ self beNeedsAttention: 'git repo does not exist' ].

	"Test, if can be updated from remote branch"
	"OPTIMIZE: A bit dirty"
	((self core readCommand: ((self gitCommand: 'remote update'), ' && ', (self gitCommand: 'status -uno')) )
		includesSubstring: 'Your branch is up to date') ifFalse: [
			^ self beNeedsAttention: 'Probably can be updated, see log'
		]
]

{ #category : 'as yet unclassified' }
GSCGitRepository >> doCloneFromGitRepo [
	| path |
	path := self folderPath pathString.
	
	self runSudoShellCommand: ('mkdir -p ', path) then: [
		self runSudoShellCommand: ('chown ', (self serverUsername), ' ', path) then: [

			self runShellCommand: ('git clone --branch ', self branch, ' ', self url, ' ', path) ] ]
]

{ #category : 'as yet unclassified' }
GSCGitRepository >> doPull [
	| path |
	path := self folderPath pathString.
	
	self runShellCommand: (self gitCommand: 'pull')
]

{ #category : 'accessing' }
GSCGitRepository >> folderPath [

	^ folderPath
]

{ #category : 'accessing' }
GSCGitRepository >> folderPath: anObject [

	folderPath := self core realPathForFile: anObject
]

{ #category : 'as yet unclassified' }
GSCGitRepository >> gitCommand: aString [
	^ self gitDefaultCommand, ' ', aString
]

{ #category : 'as yet unclassified' }
GSCGitRepository >> gitDefaultCommand [
	| path |
	path := self folderPath pathString.
	
	^ 'git -C "', path, '"'
]

{ #category : 'rendering' }
GSCGitRepository >> renderBodyOn: html [
	self renderLabel: 'URL' text: url on: html.
	self renderLabel: 'Target' text: folderPath pathString on: html.
	self renderLabel: 'Branch' text: branch on: html.

]

{ #category : 'accessing' }
GSCGitRepository >> title [
	^ 'git ', (url ifBlank: [ 'repository' ])
]

{ #category : 'accessing' }
GSCGitRepository >> url [

	^ url
]

{ #category : 'accessing' }
GSCGitRepository >> url: anObject [

	url := anObject
]
