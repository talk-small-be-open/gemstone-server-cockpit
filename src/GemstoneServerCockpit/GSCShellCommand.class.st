Class {
	#name : 'GSCShellCommand',
	#superclass : 'GSCTool',
	#instVars : [
		'cmd',
		'checkMeBlock',
		'title',
		'sudo',
		'args'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'accessing' }
GSCShellCommand >> args [

	^ args
]

{ #category : 'accessing' }
GSCShellCommand >> args: anObject [

	args := anObject
]

{ #category : 'as yet unclassified' }
GSCShellCommand >> checkMe [
	self beNotNeedsAttention.
	
	checkMeBlock ifNotNil: [ checkMeBlock cull: self ]
]

{ #category : 'accessing' }
GSCShellCommand >> checkMeBlock [

	^ checkMeBlock
]

{ #category : 'accessing' }
GSCShellCommand >> checkMeBlock: anObject [

	checkMeBlock := anObject
]

{ #category : 'accessing' }
GSCShellCommand >> cmd [

	^ cmd
]

{ #category : 'accessing' }
GSCShellCommand >> cmd: anObject [

	cmd := anObject
]

{ #category : 'as yet unclassified' }
GSCShellCommand >> commandlineString [
	"Get the command as a oneliner for execution in a shell"
	^ String streamContents: [ :s |
		s << cmd.
		args do: [ :each |
			| quote |
			
			"TODO Autoescape. Put that in a general usable place"
			
			quote := each includes: Character space.
			
			s space.
			quote ifTrue: [ s << $" ].
			s << each.
			quote ifTrue: [ s << $" ].
		]
	]
]

{ #category : 'as yet unclassified' }
GSCShellCommand >> depotScript: aScriptName [
	^ self depotScript: aScriptName args: nil

]

{ #category : 'as yet unclassified' }
GSCShellCommand >> depotScript: aScriptName args: anArgsCollection [
	| command |
	command := (self core fileDepotScriptsDir / aScriptName) pathString.
	
	self cmd: command.
	self args: anArgsCollection
]

{ #category : 'as yet unclassified' }
GSCShellCommand >> doExecute [
	self isSudo ifTrue: [ 
		self runSudoShellCommand: cmd args: args.
	] ifFalse: [ 
		self runShellCommand: cmd args: args.
	]
]

{ #category : 'as yet unclassified' }
GSCShellCommand >> gscGemstoneExecute: aGemstoneShellCommand [
	^ self gscGemstoneExecute: aGemstoneShellCommand args: nil
]

{ #category : 'as yet unclassified' }
GSCShellCommand >> gscGemstoneExecute: aGemstoneShellCommand args: anArgsCollection [
	| ensuredArgs |

	"Robustness to nil"
	ensuredArgs := anArgsCollection ifNil: [ {  } ].
	
	self depotScript: 'gsc-gemstone-execute.sh' args: (ensuredArgs copyWithFirst: aGemstoneShellCommand)

]

{ #category : 'testing' }
GSCShellCommand >> isSudo [
	^ sudo = true
]

{ #category : 'rendering' }
GSCShellCommand >> renderBodyOn: html [
	self renderLabel: 'Command' text: self cmd on: html.
]

{ #category : 'accessing' }
GSCShellCommand >> title [
	^ 'Shell: ', (title ifBlank: [ cmd ])
]

{ #category : 'accessing' }
GSCShellCommand >> title: aString [
	title := aString
]

{ #category : 'as yet unclassified' }
GSCShellCommand >> useSudo [
	sudo := true
]
