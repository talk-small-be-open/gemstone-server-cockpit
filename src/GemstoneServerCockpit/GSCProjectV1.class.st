Class {
	#name : #GSCProjectV1,
	#superclass : #GSCProject,
	#category : #GemstoneServerCockpit
}

{ #category : #'as yet unclassified' }
GSCProjectV1 >> createAnsibleFiles [
	| inventory host ansibleVars |
	"Generate gsc_ansible_vars.yml"
	ansibleVars := Dictionary new.
	ansibleVars at: 'gsc' put: self config asNestedDictionary.
	(self folder / 'gsc_ansible_vars.json') ensureDelete writeStreamDo: [ :s |
		self putJson: ansibleVars onStream: s.
	].

	"Template
all:
  hosts:
    192.168.10.60:
      ansible_user: root
      ansible_python_interpreter: /usr/bin/python3
"
	inventory := GSCEasyConfigurationBuilder new.
	host := inventory all hosts at: (self config server hostname).
	host
		ansible_user: (self config server username);
		ansible_python_interpreter: '/usr/bin/python3'.

	(self folder / 'inventory.json') ensureDelete writeStreamDo: [ :s |
		self putJson: inventory asNestedDictionary onStream: s.
	].
	
	"Copy files in project folder"
]

{ #category : #'as yet unclassified' }
GSCProjectV1 >> deploy [
	"TODO"
	OSPlatform current runCommand: 'deploy.sh'
]

{ #category : #'as yet unclassified' }
GSCProjectV1 >> handleCommandline: aGscCliHandler [
	
	(aGscCliHandler hasOption: 'info') ifTrue: [
		aGscCliHandler stdout 
			nextPutAll: (config project name);
			lf.
		^ aGscCliHandler exitSuccess ].
		
	(aGscCliHandler hasOption: 'createansible') ifTrue: [
		self createAnsibleFiles.
		^ aGscCliHandler exitSuccess ].

	(aGscCliHandler hasOption: 'deploy') ifTrue: [
		self deploy.
		^ aGscCliHandler exitSuccess ].

	"no args? do nothing, stay open, should be UI"
	aGscCliHandler hasArguments
		ifTrue: [ ^ aGscCliHandler exitFailure ]
		ifFalse: [ aGscCliHandler openGui ]
]
