Class {
	#name : 'GSCHaproxy',
	#superclass : 'GSCTool',
	#instVars : [
		'statusHtml'
	],
	#category : 'GemstoneServerCockpit-Model',
	#package : 'GemstoneServerCockpit',
	#tag : 'Model'
}

{ #category : 'building' }
GSCHaproxy >> build [

	self add: GSCAptPackage then: [ :apt |
		apt packageName: 'haproxy' ].
	
	self add: GSCTextFile then: [ :file |
		file
			filePath: self configFilePath;
			beRootOwned;
			contentTemplate: self haproxyConfigTemplate
	].

	self add: GSCSystemService then: [ :service |
		service name: 'haproxy'
	].

"	self add: GSCExternalWebTool then: [ :web |
		web url: '/ha-status' ]"
]

{ #category : 'as yet unclassified' }
GSCHaproxy >> configFilePath [
	^ '/etc/haproxy/haproxy.cfg' asPath
]

{ #category : 'rendering' }
GSCHaproxy >> doCheckSyntax [
	self runSudoShellCommand: 'haproxy -c -- ', self configFilePath pathString
]

{ #category : 'rendering' }
GSCHaproxy >> doViewWebStatus [
	statusHtml := self core sudoReadCommand: 'curl' args: { '--silent'. 'http://127.0.0.1:8404/stats'. }.
]

{ #category : 'as yet unclassified' }
GSCHaproxy >> haproxyConfigTemplate [
	^ self scheme templateHaproxyConfig
		tool: self;
		yourself
]

{ #category : 'as yet unclassified' }
GSCHaproxy >> haproxySiteConfigs [
	^ (self rootFindTools: GSCHaproxySite) collect: [ :each | each haproxyConfigTemplate ]
]

{ #category : 'rendering' }
GSCHaproxy >> renderBodyOn: html [
	statusHtml ifNotBlank: [
		html iframe
			style: 'width: 100%; height: 1000px';
			contents: [ :h | h html: statusHtml ] ]
]

{ #category : 'accessing' }
GSCHaproxy >> title [
	^ 'HAproxy balancer'
]
