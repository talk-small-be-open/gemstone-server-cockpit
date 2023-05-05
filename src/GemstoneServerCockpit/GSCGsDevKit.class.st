Class {
	#name : #GSCGsDevKit,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCGsDevKit >> doCloneFromGitRepo [
	self runShellCommand: 'git clone https://github.com/GsDevKit/GsDevKit_home.git /opt/GsDevKit_home'
]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> doInstallScript [
	self runShellCommand: 'installServerClient'
]
