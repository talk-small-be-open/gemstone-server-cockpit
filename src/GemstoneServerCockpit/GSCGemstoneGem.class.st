Class {
	#name : #GSCGemstoneGem,
	#superclass : #GSCTool,
	#instVars : [
		'gemIndex',
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

	"Seaside web server in gem"
	self add: GSCGemstoneGemWebserver
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> doShowGemLog [

	self uiTailFile: self gemLogPath
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
GSCGemstoneGem >> gemFilesBasename [
	^ 'seaside', self gemIndex asString, '_server-', self portNumber asString
]

{ #category : #accessing }
GSCGemstoneGem >> gemIndex [

	^ gemIndex
]

{ #category : #accessing }
GSCGemstoneGem >> gemIndex: anObject [

	gemIndex := anObject
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> gemLogPath [
	^ self stoneBasePath / 'logs' / (self gemFilesBasename, '.log')
]

{ #category : #accessing }
GSCGemstoneGem >> gsHome [
	^ self gemstoneGsHome pathString
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> monitCheckName [
	^ (self appShortCode, '_gemstone_gem_', self gemIndex asString)
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> monitConfigTemplate [
	^ self scheme templateGemMonitConfig
		tool: self;
		yourself
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> pidFilePath [
	^ self stoneBasePath / 'logs' / (self gemFilesBasename, '.pid')
]

{ #category : #accessing }
GSCGemstoneGem >> portNumber [
	^ self parent startPort + gemIndex - 1
]

{ #category : #rendering }
GSCGemstoneGem >> renderBodyOn: html [
	self renderLabel: 'Port' number: self portNumber on: html
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> stoneBasePath [
	^ self stoneTool basePath
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> stoneName [
	^ self appShortCode
]

{ #category : #'as yet unclassified' }
GSCGemstoneGem >> stoneTool [
	^ self appFindTool: GSCGemstoneStone
]

{ #category : #accessing }
GSCGemstoneGem >> title [
	^ 'web gem ', gemIndex asString
]
