Class {
	#name : #GSCGsDevKit,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCGsDevKit >> build [
	self add: GSCGitRepository then: [ :git |
		git
			folderPath: self gsHome;
			url: self repoUrl
	].

	self add: GSCTextFile then: [ :file |
		file
			filePath: '/etc/profile.d/Z99-gsdevkit.sh';
			beRootOwned;
			contentTemplate: (GSCSimpleTemplate source: ('
# Env vars for GemStone
export GS_HOME=', self gsHome pathString, '
export PATH=$GS_HOME/bin:$PATH
'))
	].

	"Use a bit more than 2GB of max shared memory, since the 'Limited' GemStone license will give us 2GB"
	self add: GSCLineInFile then: [ :lif |
		lif
			filePath: '/etc/sysctl.conf';
			search: 'kernel.shmmax=';
			line: ('kernel.shmmax=', (2.5*1024*1024*1024) asInteger asString)
	].
	self add: GSCLineInFile then: [ :lif |
		lif
			filePath: '/etc/sysctl.conf';
			search: 'kernel.shmall=';
			line: ('kernel.shmall=', (2.5*1024*1024*1024 / 4) ceiling asInteger asString)
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
		shell cmd: ('loginctl enable-linger ', self serverUsername)
	].

	self add: GSCGeneralTool then: [ :tool |
		tool checkMeBlock: [
			(tool core dirExists: self gsHome / 'dev/clients/tode') ifFalse: [
				tool beNeedsAttention: 'tODE client does not exist' ].
		].
		tool actionBlock: [ tool runShellCommand: 'createClient tode' ].
		tool title: 'tODE client'
	].

	"Copy our own STON file for the Seaside project"
	self add: GSCTextFile then: [ :file |
		"Why?! Seaside will be loaded from my baseline! But this has some more helper scripts packed for GemStone"
		file filePath: self gsHome / 'sys/local/server/projects/Seaside3.ston'.
		file contentTemplate: self seasideStonTemplate.
		file beUserOwned.
	].



]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> checkMe [
	self beNotNeedsAttention.
	
	self isInstalled ifFalse: [ ^ self beNeedsAttention: 'GsDevKit is not installed' ].

]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> doInstallScript [
	self runShellCommand: 'installServerClient'
]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> doStartTodeClient [
	"Does only work, if the SSH tunnel is established with X11 forwarding"
	"Will daemonize itself"
	
	| display |
	
	"Get the DISPLAY var, which is set from the sshd X11 forwarding"
	display := Smalltalk os environment at: 'DISPLAY'. 
	
	self runShellCommand: ('DISPLAY="', display, '" startClient tode')
]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> gsHome [
	^ self gemstoneGsHome
]

{ #category : #testing }
GSCGsDevKit >> isInstalled [
	^ self core fileExists: self gemstoneGsHome / 'bin/.gsdevkitSetup'

]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> repoUrl [
"	^ 'https://github.com/GsDevKit/GsDevKit_home.git'"
	
	"# inlcudes Ubuntu 22.04:"
	^ 'https://github.com/pdebruic/GsDevKit_home'

]

{ #category : #'as yet unclassified' }
GSCGsDevKit >> seasideStonTemplate [
	^ GSCSimpleTemplate source: '
TDObjectGatewayLeafNode{#name:''Seaside3'',#contents:''^ TDProjectSpecEntryDefinition new
    comment: \''\'';
    projectUrl: \''https://github.com/SeasideSt/Seaside\'';
    baseline: \''Seaside3\''
      repository: \''github://SeasideSt/Seaside:master/repository\''
      loads: #(\''Base\'' \''Core\'' \''JSON\'' \''Email\'' \''Javascript\'' \''JQuery\'' \''Production\'' \''Zinc\'' \''Tests\'');
    installScript: \''project clone --https --local Seaside3
      project install --local --url=http://gsdevkit.github.io/GsDevKit_home/GsApplicationTools.ston\'';
    gitCheckout: \''master\'';
    status: #(#\''inactive\'');
    locked: false;
    yourself''}
'
]

{ #category : #accessing }
GSCGsDevKit >> title [
	^ 'GsDevKit'
]
