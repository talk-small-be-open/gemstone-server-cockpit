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
 padding-top: 20px;
 padding-bottom: 40px;
 background-color: white;
}
div.mainTitle {
  font-size: 200%;
  font-weight: bold;
 margin-bottom: 10px;
}
div.coreToolbar {
  margin: 1em 0;
}
table {
 border-collapse: collapse;
 border: 1px solid black;
}
table td,
table th {
 border: 1px solid black;
 text-align: left;
 vertical-align: top;
}
a {
 text-decoration: none;
}
div.main {
 display: flex;
 flex-direction: column;
}
div.upperPane {
}
div.lowerPane {
}
div.lowerPane h1 {
 padding: 3px;
 background-color: #eee
}

div.lowerPane a.toolActionButton {
  border: 1px solid grey;
  display: inline-block;
  padding: 3px;
  margin: 3px 0;
}

div.lowerPane div.labelAndValue {
  margin: 1em 0;
}

div.toolsPanes {
 display: flex;
 justify-content: flex-start;
 margin-top: 5px;
 border: 1px solid black;
 align-items: stretch;
}
div.toolsPane {
 border-left: 1px solid gray;
}
div.toolsPane a.listEntry {
 display: block;
 padding: 3px;
}
div.toolsPane a.listEntry.selected {
 background-color: yellow;
}
div.toolsPane a.listEntry span.attributes {
  padding-left: 1em;
  float: right;
}
'
]
