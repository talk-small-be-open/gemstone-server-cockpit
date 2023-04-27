Class {
	#name : #GSCClapCommandLine,
	#superclass : #ClapApplication,
	#instVars : [
		'outStream',
		'gscProject'
	],
	#category : #GemstoneServerCockpit
}

{ #category : #'as yet unclassified' }
GSCClapCommandLine class >> configCommand [

	^ (ClapCommand id: #config)
		  description: 'Prints the configuration';
		  add: (ClapFlag id: #blabla);
		  yourself
]

{ #category : #'as yet unclassified' }
GSCClapCommandLine class >> createAnsibleCommand [

	^ (ClapCommand id: #'create-ansible')
		description: 'Creates the ansible deployment files for your project';
"		  add: (ClapFlag id: #blabla);"
		meaning: [ :match |
			self project createAnsibleFiles
		]
]

{ #category : #'as yet unclassified' }
GSCClapCommandLine class >> gsc [
	<commandline>
	^ (ClapCommand id: #gsc)
		description: 'Provides GemStone Server Cockpit features';
		add: ClapFlag forHelp;
		add: self configCommand;
		add: self createAnsibleCommand;
"		add: ((ClapFlag id: #whisper) description: 'Greet discretely');
		add: ((ClapFlag id: #shout) description: 'Greet loudly');"
"		add:
			((ClapFlag id: #language)
				description: 'Select language of greeting';
				add: ((ClapPositional id: #langCode)
					meaning: [ :pos | pos word asSymbol ];
					implicitMeaning: [ :arg :app | app defaultLanguage ]);
				meaning: [ :flag :app | (flag at: #langCode) value: app ]);"
"		add:
			((ClapPositional id: #who)
				description: 'Recipient of the greetings';
				multiple: true;
				implicitMeaning: [ :arg :app | app defaultRecipient ]);"
		meaning: [ :args | 
			args at: #helpFlag ifPresent: [ :help | 
				help value; exitSuccess ].
			(self with: args) execute ]
]

{ #category : #execution }
GSCClapCommandLine >> execute [
"	self outputStreamDo: [ :s |
		s << 'yeah GSC! in path '.
		s << (FileSystem workingDirectory pathString)
	]."
	
	
	| config |
	config := self readGscConfigFile.
	gscProject := GSCProject config: config.
	
	self outputStreamDo: [ :s | s << (config project name) ].
]

{ #category : #execution }
GSCClapCommandLine >> readGscConfigFile [
	"Install the source file given by aFileReference"
	| codeImporter fileReference configurator |

	fileReference := './gsc/project.st' asFileReference.
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
