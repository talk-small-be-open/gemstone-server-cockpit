Class {
	#name : 'GSCGemstoneStone',
	#superclass : 'GSCTool',
	#instVars : [
		'monitCheck'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> basePath [
	^ (self core realPathForFile: '/opt/gemstone/applications') / self appShortCode
]

{ #category : 'building' }
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
			filePath: self stoneConfFilePath;
			beUserOwned;
			contentTemplate: self gemConfTemplate
	].

	self add: GSCTextFile then: [ :file |
		file
			title: 'gem.conf file';
			filePath: self gemConfFilePath;
			beUserOwned;
			contentTemplate: self gemConfTemplate
	].

	self add: GSCTextFile then: [ :file |
		file
			title: 'gemstone.env file';
			filePath: self gemstoneEnvFilePath;
			beUserOwned;
			contentTemplate: self gemstoneEnvTemplate
	].


	"TODO only if not installed already"
"	self add: GSCGeneralTool then: [ :tool |
		tool title: 'Mount seaside in tode'.
		tool actionBlock: [ tool runTodeCommand: 'mount @/sys/stone/dirs/Seaside3/tode /home seaside' stone: self stoneName ].
	]."


	(self configAt: 'sourceCode') dataDo: [ :key :conf |
		self add: GSCMetacelloProject then: [ :project |
			project
				projectName: (conf at: 'metacelloName');
				gitBranch: (conf at: 'gitBranch');
				gitUrl: (conf at: 'gitUrl').
		]
	].

	"Backup cron job"
	self add: GSCCronJob then: [ :cron |
		cron
			minute: '0';
			hour: '1,12';
			title: (self stoneName, ' GemStone DB backup');
			command: ((self core fileDepotScriptsDir / 'backup-gemstone-db.sh') pathString, ' ', self appShortCode) ].

	"Cleanup tranlogs cron job"
	self add: GSCCronJob then: [ :cron |
		cron
			minute: '0';
			hour: '3';
			title: (self stoneName, ' GemStone cleanup (tranlogs, objectlog, logfiles, ...)');
			command: ((self core fileDepotScriptsDir / 'cleanup.sh') pathString, ' ', self appShortCode) ]

]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> checkMe [
	self beNotNeedsAttention.
	
	(self core fileExists: (self basePath / 'extents/extent0.dbf' )) ifFalse: [
		self beNeedsAttention: 'Stone does not exist' ]

]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> doCreateStone [
	self runDepotScript: 'create-stone.sh' args: { self appShortCode. self stoneVersion }
]

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> doShowStoneLog [
	self uiViewFile: self stoneLogPath
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> doShowStoneTime [
	self log: (self runAndPrintSmalltalk: 'DateAndTime now asString, '' in TimeZone '', TimeZone default asString' stone: self stoneName)
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> doStartNetldi [
"	self runShellCommand: ('startStone -b ', self stoneName)"
	self
		runShellCommand: (self gemstoneBinPath / 'startnetldi') pathString
		args: { '-g'. '-l'. self stoneName. }
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> doStartStone [
"	self runShellCommand: ('startStone -b ', self stoneName)"
	self
		runShellCommand: (self gemstoneBinPath / 'startstone') pathString
		args: {'-z'. self stoneConfFilePath pathString. '-l'. self stoneLogPath pathString. self stoneName. }.
		
	self doStartNetldi
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> doStopNetldi [
"	self runShellCommand: ('startStone -b ', self stoneName)"
	self
		runShellCommand: (self gemstoneBinPath / 'stopnetldi') pathString
		args: { self stoneName }
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> doStopStone [
"	self runShellCommand: ('stopStone -b ', self stoneName)"
	self doStopNetldi.
	
	self
		runShellCommand: (self gemstoneBinPath / 'stopstone') pathString
		args: { self stoneName }
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> extentFilePath [
	^ (self basePath / 'extents' / 'extent0.dbf')

]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> gemConfFilePath [
	^ (self basePath / 'gem.conf')

]

{ #category : 'as yet unclassified' }
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
GEM_TEMPOBJ_POMGEN_PRUNE_ON_VOTE = 90;

STN_TRAN_FULL_LOGGING = TRUE;
STN_TRAN_LOG_DIRECTORIES = $GEMSTONE_TRANLOGDIR/, $GEMSTONE_TRANLOGDIR/;
STN_TRAN_LOG_SIZES = 100, 100;

# Some regular expressions take 2 levels per character. So we assume texts up to 2500 characters and need 5000 depth
# default would be 1000, has been proven to be to low.
GEM_MAX_SMALLTALK_STACK_DEPTH = 5000;

# We often develop using symbols like Strings. So better to garbage collect them, too
STN_SYMBOL_GC_ENABLED = TRUE;
'
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> gemTempobjCacheSize [
	"in KB"
	| could |
	could := self hasKeyfile ifTrue: [ 500 * 1024 ] ifFalse: [ 300 * 1024 ].

	"Limited by SHR_PAGE_CACHE_SIZE_KB"
	^ could min: self shrPageCacheSizeKb
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> gemsTool [
	^ self appFindTool: GSCGemstoneGems
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> gemstoneBinPath [
	^ self gemstoneProductPath / 'bin'
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> gemstoneEnvFilePath [
	^ (self basePath / 'gemstone.env')

]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> gemstoneEnvTemplate [
	^ GSCSttTemplate tool: self sttString:
'#
# Environment variables for one specific stone
#

## Gemstone environment settings

## Stone name
export GEMSTONE_NAME=<?stt= me stoneName ?>

## Path to Stone directory
export GEMSTONE_STONE_DIR="<?stt= me basePath pathString ?>"

## Path to the Gemstone product directory
export GEMSTONE=$GEMSTONE_STONE_DIR/product

## Log directory
export GEMSTONE_LOGDIR=$GEMSTONE_STONE_DIR/logs

## Cypress git repository directory
# export GEMSTONE_GITDIR=$GEMSTONE_STONE_DIR/git

## Tranlog directory
export GEMSTONE_TRANLOGDIR=$GEMSTONE_STONE_DIR/tranlogs

## Path to the Gemstone keyfile
# export GEMSTONE_KEYFILE=$GEMSTONE/seaside/etc/gemstone.key

## Gemstone data directory
export GEMSTONE_DATADIR=$GEMSTONE_STONE_DIR/extents

## Path to Gemstone system config file
export GEMSTONE_SYS_CONF=$GEMSTONE_DATADIR/system.conf

## Path to Gemstone executable config directory
export GEMSTONE_EXE_CONF=$GEMSTONE_STONE_DIR

## NRS_ALL to define log directory for all processes
export GEMSTONE_NRS_ALL=''#dir:$GEMSTONE_LOGDIR#log:%N%P.log''

## Print instance counts and Smalltalk stack when an OutOfMemory error occurs
export GS_DEBUG_VMGC_VERBOSE_OUTOFMEM=1


### Add Gemstone paths to some common environment variables ###
### -- unless they have already been added. ###
### WARNING: assumes if paths start with $GEMSTONE they are already set ###

# Compute the length of the $GEMSTONE environment variable
GS_LEN=${#GEMSTONE}

## Gemstone and Seaside program paths
if [[ ${PATH:0:$GS_LEN} != $GEMSTONE ]] ; then
    export PATH=$GEMSTONE/bin:$PATH
fi

## Gemstone library path
if [[ ${LD_LIBRARY_PATH:0:$GS_LEN} != ${GEMSTONE} ]] ; then
    export LD_LIBRARY_PATH=$GEMSTONE/lib:$LD_LIBRARY_PATH
fi

'
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> gemstoneProductPath [
	"OPTIMIZE?"
	^ self core realPathForFile: (self
		configAt: 'gemstone:product'
		ifBlank: [
			'/opt/gemstone/products/GemStone64Bit', self stoneVersion, '-x86_64.Linux' ]
	)
]

{ #category : 'testing' }
GSCGemstoneStone >> hasKeyfile [
	^ self keyfilePath notBlank
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> keyfilePath [
	^ self configAt: 'gemstone:keyfile'
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> monitCheckName [
	^ (self appShortCode, '_gemstone_stone')
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> monitConfigTemplate [
	^ self scheme templateStoneMonitConfig
		tool: self;
		yourself
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> netldiMonitCheckName [
	^ (self appShortCode, '_gemstone_netldi')
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> netldiMonitConfigTemplate [
	^ self scheme templateNetldiMonitConfig
		tool: self;
		yourself
]

{ #category : 'rendering' }
GSCGemstoneStone >> renderBodyOn: html [
	self renderLabel: 'Stone name' text: self stoneName on: html.
	self renderLabel: 'Version' text: self stoneVersion on: html.
	self renderLabel: 'Key file' text: self keyfilePath on: html.

]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> shrPageCacheSizeKb [
	| maxTotalKb totalGems myGems limitKb myShare |

	"Calculates the max shared memory size for this stone. Since there is a maximum linux systemwide, we need
	to calculate the partial of it for that single stone"

	"OPTIMIZE: Does not use all the shared memory, if the GemStone license limits are hit. Maybe never the case, but
	the math should be preciser, for distributing the total shared memory"

	maxTotalKb := (self root sharedMemoryMaxBytes) // 1024.
	
	"Get total of gems"
	totalGems := (self root stones sumNumbers: [ :each | each gemsTool gemsCount ]) max: 1.
	myGems := self gemsTool gemsCount.
	myShare := myGems / totalGems.
	
	limitKb := self hasKeyfile ifTrue: [ 2 * (1024*1024) ] ifFalse: [ (1024*1024) ].

	"Allow for a some % leftover, since GemStone somehow takes approx 6% more than configured"
	^ ((maxTotalKb * 0.9) * myShare) asInteger min: limitKb.
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> stoneConfFilePath [
	^ self basePath / (self stoneName, '.conf')

]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> stoneLogPath [
	^ self basePath / 'logs' / (self stoneName, '.log')
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> stoneName [
	^ self appShortCode
]

{ #category : 'as yet unclassified' }
GSCGemstoneStone >> stoneVersion [
	^ self configAt: 'gemstone:version' ifBlank: [ '3.6.5' ]
]

{ #category : 'accessing' }
GSCGemstoneStone >> title [
	^ 'GemStone stone'
]
