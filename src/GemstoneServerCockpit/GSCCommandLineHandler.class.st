"
GemStone Server Cockpit

Commands:
- createAnsible
- tbd
"
Class {
	#name : #GSCCommandLineHandler,
	#superclass : #CommandLineHandler,
	#category : #'GemstoneServerCockpit-Misc'
}

{ #category : #accessing }
GSCCommandLineHandler class >> commandName [
	^ 'gsc'
]

{ #category : #accessing }
GSCCommandLineHandler class >> description [
	^ 'GemStone Server Cockpit'
]

{ #category : #activation }
GSCCommandLineHandler >> activate [

	self activateHelp ifTrue: [ ^ self ].
	
"	config := self readGscConfigFile."

"	gscProject := GSCProject config: config."
	
	"Set some init data, because we run from command line"
"	gscProject folder: FileSystem workingDirectory."

"	gscProject handleCommandline: self."


	(self hasOption: 'url') ifTrue: [
		self stdout 
			nextPutAll: GSCCore instance applicationUrl;
			lf.
		^ self exitSuccess ].

	(self hasOption: 'install') ifTrue: [
		GSCCore install.
		^ self exitSuccess ].

		
"	(self hasOption: 'createansible') ifTrue: [
		self createAnsibleFiles.
		^ self exitSuccess ]."

"	(self hasOption: 'deploy') ifTrue: [
		self deploy.
		^ self exitSuccess ]."

	"no args? do nothing, stay open, should be UI"
"	self hasArguments
		ifTrue: [ ^ self exitFailure ]
		ifFalse: [ self openGui ]"
]

{ #category : #'as yet unclassified' }
GSCCommandLineHandler >> openGui [
	GSCProjectCockpitGui open
]
