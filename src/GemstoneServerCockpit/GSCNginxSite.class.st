Class {
	#name : #GSCNginxSite,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCNginxSite >> build [

	self add: GSCTextFile then: [ :file |
		file
			filePath: ('/etc/nginx/sites-available/', self appShortName, '.vhost');
			contentTemplate: self vhostConfigTemplate
	].
]

{ #category : #'as yet unclassified' }
GSCNginxSite >> vhostConfigTemplate [
	
]
