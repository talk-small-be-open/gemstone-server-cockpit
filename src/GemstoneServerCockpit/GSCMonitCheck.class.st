Class {
	#name : #GSCMonitCheck,
	#superclass : #GSCTool,
	#instVars : [
		'checkName',
		'configTemplate'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCMonitCheck >> build [

	self add: GSCTextFile then: [ :file |
		file
			filePath: ('/etc/monit/conf.d/', checkName, '.conf');
			contentTemplate: configTemplate
	].


]

{ #category : #accessing }
GSCMonitCheck >> checkName [

	^ checkName
]

{ #category : #accessing }
GSCMonitCheck >> checkName: anObject [

	checkName := anObject
]

{ #category : #accessing }
GSCMonitCheck >> configTemplate [

	^ configTemplate
]

{ #category : #accessing }
GSCMonitCheck >> configTemplate: anObject [

	configTemplate := anObject
]

{ #category : #starting }
GSCMonitCheck >> doMonitor [
	self runSudoShellCommand: ('monit monitor "', checkName, '"')
]

{ #category : #starting }
GSCMonitCheck >> doStart [
	self runSudoShellCommand: ('monit start "', checkName, '"')
]

{ #category : #starting }
GSCMonitCheck >> doStatus [
	self runSudoShellCommand: ('monit status "', checkName, '"')
]

{ #category : #starting }
GSCMonitCheck >> doStop [
	self runSudoShellCommand: ('monit stop "', checkName, '"')
]

{ #category : #starting }
GSCMonitCheck >> doUnmonitor [
	self runSudoShellCommand: ('monit unmonitor "', checkName, '"')
]

{ #category : #accessing }
GSCMonitCheck >> title [
	^ 'Monit check ', checkName
]
