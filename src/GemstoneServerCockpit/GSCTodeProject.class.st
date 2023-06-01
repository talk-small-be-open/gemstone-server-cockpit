Class {
	#name : #GSCTodeProject,
	#superclass : #GSCTool,
	#instVars : [
		'gitUrl',
		'projectName'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCTodeProject >> build [
	self add: GSCGitRepository then: [ :git |
		git
			url: gitUrl;
			folderPath: ('/opt/GsDevKit_home/shared/repos/', self projectName)
	]
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> checkMe [
	self beNotNeedsAttention.
	
	(self core fileExists: ('/opt/GsDevKit_home/sys/local/server/projects/', self projectName, '.ston')) ifFalse: [
		self beNeedsAttention: 'metacello project not installed' ]
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> doCreateEntry [
	self runTodeCommand: 'project entry --baseline=', self projectName, ' --repo=\"filetree://', self localRepoPath, '/src\" /sys/local/server/projects' stone: self stoneName.

]

{ #category : #'as yet unclassified' }
GSCTodeProject >> doGet [
	self runTodeCommand: ('project get ', self projectName) stone: self stoneName
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> doLoad [
	self runTodeCommand: ('project load --loads="\`#(''default'')\`" ', self projectName) stone: self stoneName

]

{ #category : #accessing }
GSCTodeProject >> gitUrl [

	^ gitUrl
]

{ #category : #accessing }
GSCTodeProject >> gitUrl: anObject [

	gitUrl := anObject
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> localRepoPath [
	^ '/opt/GsDevKit_home/shared/repos/', self projectName

]

{ #category : #accessing }
GSCTodeProject >> projectName [

	^ projectName
]

{ #category : #accessing }
GSCTodeProject >> projectName: anObject [

	projectName := anObject
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> stoneName [
	^ self stoneTool stoneName
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> stoneTool [
	^ self ancestorsDetectKindOf: GSCGemstoneStone
]
