Class {
	#name : 'GSCZincServerAdaptor',
	#superclass : 'ZnZincServerAdaptor',
	#category : 'GemstoneServerCockpit-Misc',
	#package : 'GemstoneServerCockpit',
	#tag : 'Misc'
}

{ #category : 'defaults' }
GSCZincServerAdaptor >> defaultZnServer [
	server := ZnServer on: self port.
	
	"localhost access only, too dangerous else"
	server bindingAddress: #[127 0 0 1].
	
	^ server
]
