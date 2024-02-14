Class {
	#name : #GSCGemstoneStone,
	#superclass : #GSCTool,
	#instVars : [
		'monitCheck'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> OPTIMIZEInstallGermanDateNames [
	| smalltalk |
	
	" See file /opt/GsDevKit_home/shared/downloads/products/GemStone64Bit3.4.5-x86_64.Linux/upgrade/installtimezone.txt"

	"DOES NOT WORK"	
"	smalltalk := '
(ChronologyConstants classVarAt: ''DayNames'')
at: 1 put: #''Montag'';
at: 2 put: #''Dienstag'';
at: 3 put: #''Mittwoch'';
at: 4 put: #''Donnerstag'';
at: 5 put: #''Freitag'';
at: 6 put: #''Samstag'';
at: 7 put: #''Sonntag''.

(ChronologyConstants classVarAt: ''MonthNames'')
at: 1 put: #''Januar'';
at: 2 put: #''Februar'';
at: 3 put: #''März'';
at: 4 put: #''April'';
at: 5 put: #''Mai'';
at: 6 put: #''Juni'';
at: 7 put: #''Juli'';
at: 8 put: #''August'';
at: 9 put: #''September'';
at: 10 put: #''Oktober'';
at: 11 put: #''November'';
at: 12 put: #''Dezember''.
'."

	"self runSmalltalk: smalltalk stone: self stoneName"

]

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
			beUserOwned;
			contentTemplate: self gemConfTemplate
	].

	"TODO only if not installed already"
	self add: GSCGeneralTool then: [ :tool |
		tool title: 'Mount seaside in tode'.
		tool actionBlock: [ tool runTodeCommand: 'mount @/sys/stone/dirs/Seaside3/tode /home seaside' stone: self stoneName ].
"TODO		tool checkMeBlock: "
	].

	(self configAt: 'sourceCode') dataDo: [ :key :conf |
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
	
	(self core fileExists: (self basePath / 'extents/extent0.dbf' )) ifFalse: [
		self beNeedsAttention: 'Stone does not exist' ]

]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> doCreateStone [
	self runShellCommand: ('createStone ', self stoneName, ' ', self stoneVersion)
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> doInstallSwissTimeZone [
	| topaz |
	
	" See file /opt/GsDevKit_home/shared/downloads/products/GemStone64Bit3.4.5-x86_64.Linux/upgrade/installtimezone.txt"
	
	topaz := '
set user SystemUser
set password swordfish
login
run
| aTimeZone |
aTimeZone := TimeZone named: ''Europe/Zurich''.
TimeZone default become: aTimeZone.
TimeZone default installAsCurrentTimeZone.
%
commit
logout
exit
'.

	self runTopaz: topaz stone: self stoneName

]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> doShowStoneLog [
	self uiViewFile: self stoneLogPath
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> doShowStoneTime [
	self log: (self runAndPrintSmalltalk: 'DateAndTime now asString, '' in TimeZone '', TimeZone default asString' stone: self stoneName)
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> doStartStone [
	self runShellCommand: ('startStone -b ', self stoneName)
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> doStopStone [
	self runShellCommand: ('stopStone -b ', self stoneName)
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> gemConfTemplate [
	^ GSCSttTemplate tool: self sttString:
'#
# standard gem.conf file for dev kit gems
#
<?stt me hasKeyfile ifTrue: [ ?>
KEYFILE = <?stt= me keyfilePath ?>;
<?stt ] ?>
# SHR_PAGE_CACHE_SIZE_KB should always be > GEM_TEMPOBJ_CACHE_SIZE
SHR_PAGE_CACHE_SIZE_KB = <?stt= me shrPageCacheSizeKb ?>;
GEM_TEMPOBJ_CACHE_SIZE = <?stt= me gemTempobjCacheSize ?>;

STN_TRAN_FULL_LOGGING = TRUE;
STN_TRAN_LOG_DIRECTORIES = $GEMSTONE_TRANLOGDIR/, $GEMSTONE_TRANLOGDIR/;
STN_TRAN_LOG_SIZES = 100, 100;

# Some regular expressions take 2 levels per character. So we assume texts up to 2500 characters and need 5000 depth
# default would be 1000, has been proven to be to low.
GEM_MAX_SMALLTALK_STACK_DEPTH = 5000;
'
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> gemTempobjCacheSize [
	"in KB"
	^ self hasKeyfile ifTrue: [ 500 * 1024 ] ifFalse: [ 300 * 1024 ]
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
	^ self scheme templateStoneMonitConfig
		tool: self;
		yourself
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> netldiMonitCheckName [
	^ (self appShortCode, '_gemstone_netldi')
]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> netldiMonitConfigTemplate [
	^ self scheme templateNetldiMonitConfig
		tool: self;
		yourself
]

{ #category : #rendering }
GSCGemstoneStone >> renderBodyOn: html [
	self renderLabel: 'Stone name' text: self stoneName on: html.
	self renderLabel: 'Version' text: self stoneVersion on: html.
	self renderLabel: 'Key file' text: self keyfilePath on: html.

]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> shrPageCacheSizeKb [
	| maxTotalKb total limitKb |

	"Calculates the max shared memory size for this stone. Since there is a maximum linux systemwide, we need
	to calculate the partial of it for that single stone"

	"OPTIMIZE: Does not use all the shared memory, if the GemStone license limits are hit. Maybe never the case, but
	the math should be preciser, for distributing the total shared memory"

	maxTotalKb := (self root gsDevKit sharedMemoryMaxBytes) // 1024.
	
	total := self root stones size max: 1.
	
	limitKb := self hasKeyfile ifTrue: [ 2 * (1024*1024) ] ifFalse: [ (1024*1024) ].

	"Allow for a 8% leftover, since GemStone somehow takes approx 6% more than configured"
	^ ((maxTotalKb * 0.92) // total) asInteger min: limitKb.

]

{ #category : #'as yet unclassified' }
GSCGemstoneStone >> stoneLogPath [
	^ self basePath / 'logs' / (self stoneName, '.log')
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
