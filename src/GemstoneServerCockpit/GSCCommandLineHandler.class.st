"
GemStone Server Cockpit

Commands:
- createAnsible
- tbd
"
Class {
	#name : #GSCCommandLineHandler,
	#superclass : #CommandLineHandler,
	#instVars : [
		'gscProject'
	],
	#category : #GemstoneServerCockpit
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
	| config |

	self activateHelp
		ifTrue: [ ^ self ].
	
	config := self readGscConfigFile.

	gscProject := GSCProject config: config.
	
	"Set some init data, because we run from command line"
	gscProject folder: FileSystem workingDirectory.

	gscProject handleCommandline: self.

]

{ #category : #accessing }
GSCCommandLineHandler >> gscProject [

	^ gscProject
]

{ #category : #accessing }
GSCCommandLineHandler >> gscProject: anObject [

	gscProject := anObject
]

{ #category : #'as yet unclassified' }
GSCCommandLineHandler >> openGui [
	GSCProjectCockpitGui open
]

{ #category : #execution }
GSCCommandLineHandler >> readGscConfigFile [
	"Install the source file given by aFileReference"
	| codeImporter fileReference configurator |

	fileReference := './project.st' asFileReference.
	configurator := GSCConfigurator new.
	Smalltalk at: #GSC put: configurator.
	
	fileReference exists ifFalse: [ self error: 'no file' ].
	
"	self outputStreamDo: [ :s | s << (fileReference pathString) ]."
		
	"parse the code given in the source file"
	fileReference readStreamEncoded: 'utf8' do: [ :stream |
"		| stream |
		stream := ZnCharacterReadStream on: binary encoding: 'utf8'."
"		["
			codeImporter := CodeImporter fileStream: stream.
			codeImporter logSource: false.
			codeImporter evaluateDeclarations.
"		]"
"		on: Error, OCSemanticWarning, OCSemanticError
		do: [ :e | ""tbd"" ]"
	].

	^configurator
]
