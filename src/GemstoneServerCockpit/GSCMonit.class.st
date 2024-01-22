Class {
	#name : #GSCMonit,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCMonit >> build [

	self add: GSCAptPackage then: [ :apt |
		apt packageName: 'monit' ].

	self add: GSCTextFile then: [ :file |
		file
			filePath: ('/etc/monit/monitrc');
			beRootOwned;
			mode: '0700';
			contentTemplate: self monitConfigTemplate
	].

	self add: GSCSystemService then: [ :service |
		service name: 'monit'
	].

	self add: GSCLogFileViewer then: [ :logFile |
		logFile filePath: '/var/log/monit.log'
	]
]

{ #category : #'as yet unclassified' }
GSCMonit >> doReload [
	self runSudoShellCommand: 'monit reload'
]

{ #category : #starting }
GSCMonit >> doReport [
	self runSudoShellCommand: ('monit report')
]

{ #category : #starting }
GSCMonit >> doStartAll [
	self runSudoShellCommand: ('monit start all')
]

{ #category : #starting }
GSCMonit >> doStopAll [
	self runSudoShellCommand: ('monit stop all')
]

{ #category : #starting }
GSCMonit >> doSummary [
	self runSudoShellCommand: ('monit summary')
]

{ #category : #'as yet unclassified' }
GSCMonit >> doSyntaxCheck [
	self runSudoShellCommand: 'monit -t'
]

{ #category : #building }
GSCMonit >> monitConfigTemplate [
	^ GSCSimpleTemplate source: '
set daemon 60
	with start delay 30
	
set logfile /var/log/monit.log

set idfile /var/lib/monit/id
set statefile /var/lib/monit/state

set mailserver localhost

set eventqueue
	basedir /var/lib/monit/events
	slots 100

set httpd port 2812 and
	use address localhost
	allow localhost
		 
include /etc/monit/conf.d/*
'
]

{ #category : #accessing }
GSCMonit >> title [
	^ 'Monit monitoring'
]
