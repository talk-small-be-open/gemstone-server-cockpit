Class {
	#name : #GSCWaFileLibrary,
	#superclass : #WAFileLibrary,
	#category : #'GemstoneServerCockpit-View'
}

{ #category : #accessing }
GSCWaFileLibrary >> selectorsToInclude [
	^#(styleCss)
]

{ #category : #'as yet unclassified' }
GSCWaFileLibrary >> styleCss [
	^ '

body {
	padding-top: 60px;
	padding-bottom: 40px;
	background-color: green;
}

table { 
	border-collapse: collapse;
	td, th {
		text-align: left;
		vertical-align: top;
	}
}

a { 
	text-decoration: none;
}

div.main { 
	display: flex;
	flex-direction: column;
}

div.upperPane { 
	height: 50%;
}

div.lowerPane { 
	height: 50%;
}

div.toolsPanes { 
	display: flex;
	justify-content: flex-start;
}

div.toolsPane {
	height: 100%;
	border: 1px solid black;
}

div.toolsPane a.listEntry { 
	display: block;
}

div.toolsPane a.listEntry.selected { 
	background-color: yellow;
}

'
]
