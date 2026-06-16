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
"	self add: GSCGitRepository then: [ :git |
		git
			url: gitUrl;
			branch: gitBranch;
			folderPath: self localRepoPath
	]"
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> checkMe [
	self beNotNeedsAttention.
	
"	(self core fileExists: (self root gemstoneGsHome / 'sys/local/server/projects' / self projectName , 'ston')) ifFalse: [
		self beNeedsAttention: 'Metacello project not installed' ]"
]

{ #category : 'as yet unclassified' }
GSCMetacelloProject >> doLoad [
"
run
GsDeployer deploy: [
  Metacello new
    baseline: 'Seaside3';
    repository: 'github://SeasideSt/Seaside:master/repository';
    onLock: [:ex | ex honor];
    load: #('Zinc') ].
%
"


"	| loadString |
	
	loadString := String streamContents: [ :s |
		s << '\`#('.
		
		self metacelloLoadList do: [ :each |
			s nextPut: $'.
			s << each.
			s nextPut: $'.
		] separatedBy: [ s space ].
		s << ')\`'.
	].
	
	self runTodeCommand: ('project load --loads=""', loadString, '"" ', self projectName) stone: self stoneName
"
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
	"TODO"
"	^ self appBasePathOderso / 'github-cache' / self projectName asLowercase
"
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
	^ 'Metacello project ', projectName
]
