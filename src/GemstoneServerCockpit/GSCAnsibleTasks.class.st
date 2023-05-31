Class {
	#name : #GSCAnsibleTasks,
	#superclass : #GSCTool,
	#instVars : [
		'tasks'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #adding }
GSCAnsibleTasks >> addTaskDictionary: aDictionary [
	aDictionary isDictionary ifFalse: [ self error: 'invalid format' ].

	tasks add: aDictionary
]

{ #category : #adding }
GSCAnsibleTasks >> addTaskJson: aString [
	| dict |
	dict := STONJSON fromString: aString.
	
	self addTaskDictionary: dict
]

{ #category : #adding }
GSCAnsibleTasks >> addTasksJson: aString [
	| array |
	array := STONJSON fromString: aString.
	
	array isArray ifFalse: [ self error: 'invalid format' ].
	
	array do: [ :each |
		self addTaskDictionary: each ]
]

{ #category : #'as yet unclassified' }
GSCAnsibleTasks >> ansibleEnvironmentDictionary [
	^ {
		'GS_HOME' -> '/opt/GsDevKit_home'.
		'PATH' -> '/opt/GsDevKit_home/bin:{{ ansible_env.PATH }}'.
	} asD
]

{ #category : #'as yet unclassified' }
GSCAnsibleTasks >> ansibleTasksCollection [
	^ tasks asArray
]

{ #category : #'as yet unclassified' }
GSCAnsibleTasks >> ansibleVarsDictionary [
	^ self config asDictionary
]

{ #category : #'as yet unclassified' }
GSCAnsibleTasks >> doPlay [
	| playbookFile |
	playbookFile := self core temporaryUniqueFile: 'json'.

	playbookFile writeStreamEncoded: 'utf-8' do: [ :s |
		s << self playbookJson
	].

	self runShellCommand: ('ansible-playbook ', playbookFile pathString)
]

{ #category : #'as yet unclassified' }
GSCAnsibleTasks >> doPlayCheckOnly [

]

{ #category : #'as yet unclassified' }
GSCAnsibleTasks >> doShowPlaybook [
	self log: self playbookJson
]

{ #category : #initialization }
GSCAnsibleTasks >> initialize [
	super initialize.
	
	tasks := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GSCAnsibleTasks >> playbookDictionary [
	| dict |
	
	dict := {
		'name' -> 'Playbook generated from GSC'.
		'hosts' -> 'localhost'.
		'become_user' -> 'root'.
		'become' -> true.
		'vars' -> self ansibleVarsDictionary.
		'environment' -> self ansibleEnvironmentDictionary.
		'tasks' -> self ansibleTasksCollection.
	} asD.

	^ dict
]

{ #category : #'as yet unclassified' }
GSCAnsibleTasks >> playbookJson [
	^ String streamContents: [ :s |
		(STON jsonWriter on: s)
			prettyPrint: true;
			newLine: String lf;
			nextPut: self playbookDictionary ]
]
