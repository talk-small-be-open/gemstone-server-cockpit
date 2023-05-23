Class {
	#name : #GSCGsDevKit,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCGsDevKit >> build [
	self add: GSCGitRepository then: [ :git |
		git
			folderPath: '/opt/GsDevKit_home';
			url: self repoUrl
	].

	self add: GSCGeneralTool then: [ :tool |
		tool checkMeBlock: [
			'/opt/GsDevKit_home/dev/clients/tode' asFileReference exists ifFalse: [ tool beNeedsAttention: 'tODE client does not exits' ].
		].
		tool actionBlock: [ tool runShellCommand: 'createClient tode' ].
		tool title: 'tODE client'
	].

	"Copy our own STON file for the Seaside project"
	self add: GSCTextFile then: [ :file |
		"Why?! Seaside will be loaded from my baseline! But this has some more helper scripts packed for GemStone"
		file filePath: '/opt/GsDevKit_home/sys/local/server/projects/Seaside3.ston'.
		file contentTemplate: self seasideStonTemplate
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

	self add: GSCTextFile then: [ :file |
		file
			filePath: '/etc/profile.d/Z99-gsdevkit.sh';
			contentTemplate: (GSCSimpleTemplate source: '
# Env vars for GemStone
export GS_HOME=/opt/GsDevKit_home
export PATH=$GS_HOME/bin:$PATH
')
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

{ #category : #testing }
GSCGsDevKit >> isInstalled [
	^ GSCCore instance runShellIsSuccess: ('test -f /opt/GsDevKit_home/bin/.gsdevkitSetup')

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
