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
			filePath: ('/etc/monit/conf.d/', self appShortCode, '_', checkName, '.conf');
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
	self runShellCommand: ('monit "', checkName, '" monitor')
]

{ #category : #starting }
GSCMonitCheck >> doStart [
	self runShellCommand: ('monit "', checkName, '" start')
]

{ #category : #starting }
GSCMonitCheck >> doStop [
	self runShellCommand: ('monit "', checkName, '" stop')
]

{ #category : #starting }
GSCMonitCheck >> doUnmonitor [
	self runShellCommand: ('monit "', checkName, '" unmonitor')
]

{ #category : #accessing }
GSCMonitCheck >> title [
	^ 'monit check ', checkName
]
