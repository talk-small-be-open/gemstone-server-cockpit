Class {
	#name : #GSCGemstoneGem,
	#superclass : #GSCTool,
	#instVars : [
		'portNumber',
		'monitCheck'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCGemstoneGem >> build [

	monitCheck := self add: GSCMonitCheck then: [ :check |
		check
			checkName: self monitCheckName;
			configTemplate: self monitConfigTemplate
	].

]

{ #category : #starting }
GSCGemstoneGem >> doStart [
	monitCheck doStart
]

{ #category : #starting }
GSCGemstoneGem >> doStop [
	monitCheck doStop
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> monitCheckName [
	^ ('gemstone_gem_', portNumber asString)
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> monitConfigTemplate [
	^ GSCSttTemplate tool: self sttString: '
# GEM ON PORT <?stt= me portNumber ?>
check process <?stt= me monitCheckName ?> with pidfile /opt/GsDevKit_home/server/stones/<?stt= me stoneName ?>/logs/seaside<?stt= me portNumber ?>_server-<?stt= me portNumber ?>.pid
	DEPENDS ON gemstone_netldi
	ONREBOOT START
	GROUP gemstone_gems
	MODE ACTIVE
	start program = "$GS_HOME/bin/todeIt <?stt= me stoneName ?> /home/seaside/gemServer --restart=seaside<?stt= me portNumber ?>" as uid "<?stt= me configAt: #server:username ?>" gid "adm"
	stop program = "$GS_HOME/bin/todeIt <?stt= me stoneName ?> /home/seaside/gemServer --stop=seaside<?stt= me portNumber ?>" as uid "<?stt= me configAt: #server:username ?>" gid "adm" with timeout 90 seconds
	if 7 restarts within 10 cycles then stop
	if failed url http://127.0.0.1:<?stt= me portNumber ?>/ping and content == "OK" for 2 cycles then alert
#	if totalmem > 700 Mb then alert
	if cpu > 60% for 4 cycles then alert
'
]

{ #category : #accessing }
GSCGemstoneGem >> portNumber [

	^ portNumber
]

{ #category : #accessing }
GSCGemstoneGem >> portNumber: anObject [

	portNumber := anObject
]

{ #category : #rendering }
GSCGemstoneGem >> renderBodyOn: html [
	self renderLabel: 'Port' number: portNumber on: html
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> stoneName [
	^ self configAt: 'gemstone:stoneName'
]
