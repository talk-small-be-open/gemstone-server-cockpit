Class {
	#name : 'GSCGsDevPlain',
	#superclass : 'GSCGsDevBase',
	#category : 'GemstoneServerCockpit-GsDevPlain',
	#package : 'GemstoneServerCockpit',
	#tag : 'GsDevPlain'
}

{ #category : 'building' }
GSCGsDevPlain >> build [
	| shmmax pageSize |
"	self add: GSCGitRepository then: [ :git |
		git
			folderPath: self gsHome;
			url: self repoUrl
	].
"
"	self add: GSCTextFile then: [ :file |
		file
			filePath: '/etc/profile.d/Z99-gsdevkit.sh';
			beRootOwned;
			contentTemplate: (GSCSimpleTemplate source: (
'# Env vars for GemStone
export GS_HOME=', self gsHome pathString, '
export PATH=$GS_HOME/bin:$PATH'))
	]."

	"Use 75% of total RAM for max shared memory. The 'Limited' GemStone license will give us only max 2GB per stone"
	pageSize := self root factAt: 'memoryPageSizeBytes'.
	shmmax := self root sharedMemoryMaxBytes.
	self add: GSCLineInFile then: [ :lif |
		lif
			filePath: '/etc/sysctl.conf';
			search: 'kernel.shmmax=';
			line: ('kernel.shmmax=', shmmax asString)
	].
	self add: GSCLineInFile then: [ :lif |
		lif
			filePath: '/etc/sysctl.conf';
			search: 'kernel.shmall=';
			line: ('kernel.shmall=', (shmmax / pageSize) ceiling asInteger asString)
	].

	"systemd parameter RemoveIPC for GemStone"
	self add: GSCLineInFile then: [ :lif |
		lif
			filePath: '/etc/systemd/logind.conf';
			search: 'RemoveIPC=';
			line: 'RemoveIPC=no'
	].

	"systemd parameter KillUserProcesses for GemStone"
	self add: GSCLineInFile then: [ :lif |
		lif
			filePath: '/etc/systemd/logind.conf';
			search: 'KillUserProcesses=';
			line: 'KillUserProcesses=no'
	].

	self add: GSCShellCommand then: [ :shell |
		shell cmd: 'loginctl'.
		shell args: {'enable-linger'. self serverUsername}
	].


	"Copy our own STON file for the Seaside project"
"	self add: GSCTextFile then: [ :file |
		""Why?! Seaside will be loaded from my baseline! But this has some more helper scripts packed for GemStone""
		file filePath: self gsHome / 'sys/local/server/projects/Seaside3.ston'.
		file contentTemplate: self seasideStonTemplate.
		file beUserOwned.
	].
"


]

{ #category : 'as yet unclassified' }
GSCGsDevPlain >> checkMe [
	self beNotNeedsAttention.
	
"	self isInstalled ifFalse: [ ^ self beNeedsAttention: 'GsDevKit is not installed' ].
"
]

{ #category : 'accessing' }
GSCGsDevPlain >> title [
	^ 'GemStone plain development'
]
