Class {
	#name : #GSCGemstoneStone,
	#superclass : #GSCTool,
	#instVars : [
		'monitCheck'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> basePath [
	^ self gemstoneGsHome / 'server/stones' / self stoneName
]

{ #category : #building }
GSCGemstoneStone >> build [

	monitCheck := self add: GSCMonitCheck then: [ :check |
		check
			checkName: self monitCheckName;
			configTemplate: self monitConfigTemplate
	].

	monitCheck := self add: GSCMonitCheck then: [ :check |
		check
			checkName: self netldiMonitCheckName;
			configTemplate: self netldiMonitConfigTemplate
	].

	self add: GSCTextFile then: [ :file |
		file
			title: 'stone.conf file';
			filePath: (self basePath / (self stoneName, '.conf'));
			contentTemplate: self gemConfTemplate
	].

	"TODO only if not installed already"
	self add: GSCGeneralTool then: [ :tool |
		tool title: 'Mount seaside in tode'.
		tool actionBlock: [ tool runTodeCommand: 'mount @/sys/stone/dirs/Seaside3/tode /home seaside' stone: self stoneName ].
"TODO		tool checkMeBlock: "
	].

	(self configAt: 'sourceCode') keysAndValuesDo: [ :key :conf |
		self add: GSCTodeProject then: [ :project |
			project
				projectName: (conf at: 'metacelloName');
				gitBranch: (conf at: 'gitBranch');
				gitUrl: (conf at: 'gitUrl').
		]
	]
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> checkMe [
	self beNotNeedsAttention.
	
	(self core fileExists: (self gemstoneGsHome / 'server/stones' / self stoneName / 'extents/extent0.dbf' )) ifFalse: [
		self beNeedsAttention: 'Stone does not exist' ]

]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> doCreateStone [
	self runShellCommand: ('createStone ', self stoneName, ' ', self stoneVersion)
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> gemConfTemplate [
	^ GSCSttTemplate tool: self sttString: '
#
# standard gem.conf file for dev kit gems
#

# SHR_PAGE_CACHE_SIZE_KB should always be > GEM_TEMPOBJ_CACHE_SIZE
# Problems with limited license key. Could not get 2G of shared. SHR_PAGE_CACHE_SIZE_KB = 2000000;
<?stt me hasKeyfile ifTrue: [ ?>
KEYFILE = <?stt= me keyfilePath ?>;
SHR_PAGE_CACHE_SIZE_KB = 2GB;
GEM_TEMPOBJ_CACHE_SIZE = 300MB;
<?stt ] ifFalse: [ ?>
SHR_PAGE_CACHE_SIZE_KB = 1GB;
GEM_TEMPOBJ_CACHE_SIZE = 300MB;
<?stt ] ?>

STN_TRAN_FULL_LOGGING = TRUE;
STN_TRAN_LOG_DIRECTORIES = $GEMSTONE_TRANLOGDIR/, $GEMSTONE_TRANLOGDIR/;
STN_TRAN_LOG_SIZES = 100, 100;

# Some regular expressions take 2 levels per character. So we assume texts up to 2500 characters and need 5000 depth
# default would be 1000, has been proven to be to low.
GEM_MAX_SMALLTALK_STACK_DEPTH = 5000;
'
]

{ #category : #accessing }
GSCGemstoneStone >> gsHome [
	^ self gemstoneGsHome pathString
]

{ #category : #testing }
GSCGemstoneStone >> hasKeyfile [
	^ self keyfilePath notBlank
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> keyfilePath [
	^ self configAt: 'gemstone:keyfile'
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> monitCheckName [
	^ (self appShortCode, '_gemstone_stone')
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> monitConfigTemplate [
	^ GSCSttTemplate tool: self sttString: '
# STONE
check process <?stt= me monitCheckName ?> matching "^/opt/.*/sys/stoned <?stt= me stoneName ?> .*$"
			ONREBOOT START
			MODE ACTIVE
			start program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> <?stt= me gsHome ?>/bin/startStone <?stt= me stoneName ?>''" as uid "<?stt= me serverUsername ?>" gid "<?stt= me serverUsername ?>"
			stop program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> <?stt= me gsHome ?>/bin/stopStone <?stt= me stoneName ?>''" as uid "<?stt= me serverUsername ?>" gid "<?stt= me serverUsername ?>"
 			if 7 restarts within 10 cycles then stop
#			if totalmem > 700 Mb then alert
			if cpu > 60% for 4 cycles then alert
'


]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> netldiMonitCheckName [
	^ (self appShortCode, '_gemstone_netldi')
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> netldiMonitConfigTemplate [

	"TBD Maybe starting needs the USER and HOME env vars?!"

	^ GSCSttTemplate tool: self sttString: '
# NETLDI
check process <?stt= me netldiMonitCheckName ?> matching "^/opt/.*/sys/netldid <?stt= me stoneName ?>_ldi .*$"
			ONREBOOT START
			DEPENDS ON <?stt= me monitCheckName ?>
			MODE ACTIVE
			start program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> <?stt= me gsHome ?>/bin/startNetldi <?stt= me stoneName ?>''" as uid "<?stt= me serverUsername ?>" gid "adm"
			stop program = "/bin/bash -c ''GS_HOME=<?stt= me gsHome ?> <?stt= me gsHome ?>/bin/stopNetldi <?stt= me stoneName ?>''" as uid "<?stt= me serverUsername ?>" gid "adm" with timeout 90 seconds
 			if 7 restarts within 10 cycles then stop
#			if totalmem > 700 Mb then alert
			if cpu > 60% for 4 cycles then alert
'
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> stoneName [
	^ self appShortCode
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> stoneVersion [
	^ self configAt: 'gemstone:version' ifBlank: [ '3.6.5' ]
]

{ #category : #accessing }
GSCGemstoneStone >> title [
	^ 'GemStone stone'
]
