Class {
	#name : 'GSCAnsibleTasks',
	#superclass : 'GSCTool',
	#instVars : [
		'tasks'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'adding' }
GSCAnsibleTasks >> addTaskDictionary: aDictionary [
	aDictionary isDictionary ifFalse: [ self error: 'invalid format' ].

	tasks add: aDictionary
]

{ #category : 'adding' }
GSCAnsibleTasks >> addTaskJson: aString [
	| dict |
	dict := STONJSON fromString: aString.
	
	self addTaskDictionary: dict
]

{ #category : 'adding' }
GSCAnsibleTasks >> addTasksJson: aString [
	| array |
	array := STONJSON fromString: aString.
	
	array isArray ifFalse: [ self error: 'invalid format' ].
	
	array do: [ :each |
		self addTaskDictionary: each ]
]

{ #category : 'as yet unclassified' }
GSCAnsibleTasks >> ansibleEnvironmentDictionary [
	| gsHome |
	gsHome := self gemstoneGsHome pathString.

	^ {
		'GS_HOME' -> gsHome.
		'PATH' -> (gsHome, '/bin:{{ ansible_env.PATH }}').
	} asD
]

{ #category : 'as yet unclassified' }
GSCAnsibleTasks >> ansibleTasksCollection [
	^ tasks asArray
]

{ #category : 'as yet unclassified' }
GSCAnsibleTasks >> ansibleVarsDictionary [
	| dict |
	dict := self config asDictionary.
	
	dict at: 'remoteUser' put: self serverUsername.
	
	^ dict
]

{ #category : 'as yet unclassified' }
GSCAnsibleTasks >> doPlay [
	self core sudoAsyncWriteFile: '/tmp/playbook.json' with: self playbookJson then: [
		self runSudoShellCommand: 'ansible-playbook /tmp/playbook.json' ]
]

{ #category : 'as yet unclassified' }
GSCAnsibleTasks >> doPlayCheckOnly [
	self core sudoAsyncWriteFile: '/tmp/playbook-checkonly.json' with: self playbookJson then: [
		self runSudoShellCommand: 'ansible-playbook --check /tmp/playbook-checkonly.json' ]
]

{ #category : 'as yet unclassified' }
GSCAnsibleTasks >> doShowPlaybook [
	self uiViewText: self playbookJson
]

{ #category : 'initialization' }
GSCAnsibleTasks >> initialize [
	super initialize.
	
	tasks := OrderedCollection new
]

{ #category : 'as yet unclassified' }
GSCAnsibleTasks >> playbookData [
	| play |
	
	play := {
		'name' -> 'Playbook generated from GSC'.
		'hosts' -> 'localhost'.
		'become_user' -> 'root'.
		'become' -> true.
		'vars' -> self ansibleVarsDictionary.
		'environment' -> self ansibleEnvironmentDictionary.
		'tasks' -> self ansibleTasksCollection.
	} asD.

	^ { play }
]

{ #category : 'as yet unclassified' }
GSCAnsibleTasks >> playbookJson [
	^ String streamContents: [ :s |
		(STON jsonWriter on: s)
			prettyPrint: true;
			newLine: String lf;
			nextPut: self playbookData ]
]

{ #category : 'accessing' }
GSCAnsibleTasks >> title [
	^ 'Ansible script'
]
