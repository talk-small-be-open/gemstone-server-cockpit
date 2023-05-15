Class {
	#name : #GSCGsDevKit,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCGsDevKit >> checkMe [
	self beNotNeedsAttention.
	
	self isInstalled ifFalse: [ ^ self beNeedsAttention: 'GsDevKit is not installed' ].

]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> doCloneFromGitRepo [
	self runSudoShellCommand: ('mkdir -p /opt/GsDevKit_home && chown ', (self configAt: 'server:username'), ' /opt/GsDevKit_home') then: [
		self runShellCommand: ('git clone ', self repoUrl, ' /opt/GsDevKit_home') ]
]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> doInstallScript [
	self runShellCommand: 'installServerClient'
]

{ #category : #testing }
GSCGsDevKit >> isInstalled [
	^ GSCCore instance runShellIsSuccess: ('test -f /opt/GsDevKit_home/bin/.gsdevkitSetup')

]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> repoUrl [
"	^ 'https://github.com/GsDevKit/GsDevKit_home.git'"
	
	"# inlcudes Ubuntu 22.04:"
	^ 'https://github.com/pdebruic/GsDevKit_home'

]

{ #category : #accessing }
GSCGsDevKit >> title [
	^ 'GsDevKit'
]
