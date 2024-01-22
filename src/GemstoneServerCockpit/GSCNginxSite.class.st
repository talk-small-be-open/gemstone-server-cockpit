Class {
	#name : #GSCNginxSite,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCNginxSite >> appUrlPaths [
	^ self configAt: 'web:appUrlPaths'
]

{ #category : #building }
GSCNginxSite >> build [

	self add: GSCTextFile then: [ :file |
		file
			beRootOwned;
			filePath: ('/etc/nginx/sites-available/', self siteFileName);
			contentTemplate: self vhostConfigTemplate
	].
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> doDisableSite [
	self runSudoShellCommand: 'rm /etc/nginx/sites-enabled/', self siteFileName
	"TODO: Reload nginx here?"
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> doEnableSite [
	self runSudoShellCommand: 'ln -s /etc/nginx/sites-available/', self siteFileName, ' /etc/nginx/sites-enabled/'
	"TODO: Reload nginx here?"
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> domains [
	^ self configAt: 'web:domains'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> haproxyPortNumber [
	^ 9000
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> nginxDomainsString [
	^ self domains joinUsing: String space
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> siteFileName [
	^ self appShortCode, '.vhost'
]

{ #category : #accessing }
GSCNginxSite >> title [
	^ 'nginx site'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> tmpDir [
	^ (self configAt: 'tmpDir') ifNotBlank: [ :string | string asPath ]
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> useSsl [
	^ self configAt: 'web:useSsl'
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> vhostConfigTemplate [
	^ self scheme templateNginxSiteVhost 
		tool: self;
		yourself
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> webRoot [
"	^ (self configAt: 'server:installationPath') asPath / self appShortCode / 'web_root'"
	^ (self configAt: 'web:webRoot') asPath
]
