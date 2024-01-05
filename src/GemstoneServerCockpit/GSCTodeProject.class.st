Class {
	#name : #GSCTodeProject,
	#superclass : #GSCTool,
	#instVars : [
		'gitUrl',
		'gitBranch',
		'projectName',
		'metacelloLoadList'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCTodeProject >> build [
	self add: GSCGitRepository then: [ :git |
		git
			url: gitUrl;
			branch: gitBranch;
			folderPath: self localRepoPath
	]
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> checkMe [
	self beNotNeedsAttention.
	
	(self core fileExists: (self gemstoneGsHome / 'sys/local/server/projects' / self projectName , 'ston')) ifFalse: [
		self beNeedsAttention: 'Metacello project not installed' ]
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> doCreateEntry [
"	self
		runTodeCommand: ('project entry --baseline=', self metacelloName, ' --repo=\""filetree://', self localRepoPath pathString, '/src\"" /sys/local/server/projects')
		stone: self stoneName."

	self
		runTodeCommand: ('project entry --baseline=', self metacelloName, ' --repo=filetree://', self localRepoPath pathString, '/src /sys/local/server/projects')
		stone: self stoneName.

]

{ #category : #'as yet unclassified' }
GSCTodeProject >> doGet [
	self runTodeCommand: ('project get ', self projectName) stone: self stoneName
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> doLoad [
	| loadString |
	
	loadString := String streamContents: [ :s |
		s << '\`#('.
		
		self metacelloLoadList do: [ :each |
			s nextPut: $'.
			s << each.
			s nextPut: $'.
		] separatedBy: [ s space ].
		s << ')\`'.
	].
	
	self runTodeCommand: ('project load --loads="', loadString, '" ', self projectName) stone: self stoneName

]

{ #category : #accessing }
GSCTodeProject >> gitBranch [

	^ gitBranch
]

{ #category : #accessing }
GSCTodeProject >> gitBranch: anObject [

	gitBranch := anObject
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
	^ self gemstoneGsHome / 'shared/repos' / self projectName asLowercase

]

{ #category : #accessing }
GSCTodeProject >> metacelloLoadList [
	^ metacelloLoadList ifBlank: [ #('default') ]
]

{ #category : #accessing }
GSCTodeProject >> metacelloLoadList: anObject [

	metacelloLoadList := anObject
]

{ #category : #'as yet unclassified' }
GSCTodeProject >> metacelloName [
	^ self projectName capitalized
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

{ #category : #accessing }
GSCTodeProject >> title [
	^ 'tode project ', projectName
]
