Class {
	#name : #GSCGemstoneStone,
	#superclass : #GSCTool,
	#instVars : [
		'monitCheck'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCGemstoneStone >> build [

	monitCheck := self add: GSCMonitCheck then: [ :check |
		check
			checkName: self monitCheckName;
			configTemplate: self monitConfigTemplate
	].

]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> monitCheckName [
	^ ('gemstone_stone_', self appShortCode)
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> monitConfigTemplate [
	^ GSCSttTemplate tool: self sttString: '
# STONE
check process <?stt= me monitCheckName ?> matching "^/opt/.*/sys/stoned <?stt= me stoneName ?> .*$"
			ONREBOOT START
			MODE ACTIVE
			start program = "$GS_HOME/bin/startStone <?stt= me stoneName ?>" as uid "<?stt= me configAt: #server:username ?>" gid "adm"
			stop program = "$GS_HOME/bin/stopStone <?stt= me stoneName ?>" as uid "<?stt= me configAt: #server:username ?>" gid "adm"
 			if 7 restarts within 10 cycles then stop
#			if totalmem > 700 Mb then alert
			if cpu > 60% for 4 cycles then alert
'


]
