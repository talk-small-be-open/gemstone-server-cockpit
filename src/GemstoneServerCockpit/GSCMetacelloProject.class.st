Class {
	#name : 'GSCMetacelloProject',
	#superclass : 'GSCTool',
	#instVars : [
		'gitUrl',
		'gitBranch',
		'projectName',
		'metacelloLoadList'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'building' }
GSCMetacelloProject >> build [
	self add: GSCGitRepository then: [ :git |
		git
			url: gitUrl;
			branch: gitBranch;
			folderPath: self localRepoPath
	]
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> checkMe [
	self beNotNeedsAttention.
	
	(self core fileExists: (self root gemstoneGsHome / 'sys/local/server/projects' / self projectName , 'ston')) ifFalse: [
		self beNeedsAttention: 'Metacello project not installed' ]
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> doCreateEntry [
"	self
		runTodeCommand: ('project entry --baseline=', self metacelloName, ' --repo=\""filetree://', self localRepoPath pathString, '/src\"" /sys/local/server/projects')
		stone: self stoneName."

	self
		runTodeCommand: ('project entry --baseline=', self metacelloName, ' --repo=filetree://', self localRepoPath pathString, '/src /sys/local/server/projects')
		stone: self stoneName.

]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> doGet [
	self runTodeCommand: ('project get ', self projectName) stone: self stoneName
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> doLoad [
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

{ #category : 'accessing' }
GSCMetacelloProject >> gitBranch [

	^ gitBranch
]

{ #category : 'accessing' }
GSCMetacelloProject >> gitBranch: anObject [

	gitBranch := anObject
]

{ #category : 'accessing' }
GSCMetacelloProject >> gitUrl [

	^ gitUrl
]

{ #category : 'accessing' }
GSCMetacelloProject >> gitUrl: anObject [

	gitUrl := anObject
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> localRepoPath [
	^ self root gemstoneGsHome / 'shared/repos' / self projectName asLowercase

]

{ #category : 'accessing' }
GSCMetacelloProject >> metacelloLoadList [
	^ metacelloLoadList ifBlank: [ #('default') ]
]

{ #category : 'accessing' }
GSCMetacelloProject >> metacelloLoadList: anObject [

	metacelloLoadList := anObject
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> metacelloName [
	^ self projectName capitalized
]

{ #category : 'accessing' }
GSCMetacelloProject >> projectName [

	^ projectName
]

{ #category : 'accessing' }
GSCMetacelloProject >> projectName: anObject [

	projectName := anObject
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> stoneName [
	^ self stoneTool stoneName
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> stoneTool [
	^ self ancestorsDetectKindOf: GSCGemstoneStone
]

{ #category : 'accessing' }
GSCMetacelloProject >> title [
	^ 'tode project ', projectName
]
