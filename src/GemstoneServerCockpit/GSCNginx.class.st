Class {
	#name : #GSCNginx,
	#superclass : #GSCTool,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #building }
GSCNginx >> build [

	self add: GSCTextFile then: [ :file |
		file
			filePath: ('/etc/nginx/nginx.conf');
			contentTemplate: self nginxConfigTemplate
	].
]

{ #category : #'as yet unclassified' }
GSCNginx >> vhostConfigTemplate [
	
]
