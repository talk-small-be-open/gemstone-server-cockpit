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
	self runSudoShellCommand: 'mkdir -f /opt/GsDevKit_home'.
	self runSudoShellCommand: 'chown ', (self configAt: 'server:username'), ' /opt/GsDevKit_home'.
	self runShellCommand: 'git clone https://github.com/GsDevKit/GsDevKit_home.git /opt/GsDevKit_home'
]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> doInstallScript [
	self runShellCommand: 'installServerClient'
]

{ #category : #testing }
GSCGsDevKit >> isInstalled [
	^ GSCCore instance runShellIsSuccess: ('test -f /opt/GsDevKit_home/bin/.gsdevkitSetup')

]

{ #category : #accessing }
GSCGsDevKit >> title [
	^ 'GsDevKit'
]
