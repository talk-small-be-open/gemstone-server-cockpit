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
div.subprocess {
	position: fixed;
	background: grey;
	padding: 1em;
	border: 1px solid black;
	top: 10%;
	bottom: 10%;
	left: 10%;
	right: 10%;
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
a.anchorButton {
	display: inline-block;
	background: blue;
	color: white;
	border: 1px solid black;
	padding: 3px;
	margin: 5px 0;
}
a.anchorButton + a.anchorButton {
	margin-left: 5px;
}

h1 { 
	font-size: 150%;
}
h2 { 
	font-size: 130%;
}
h3 { 
	font-size: 120%;
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
div.toolsPane a.listEntry:hover {
 background-color: #ddd;
}
div.toolsPane a.listEntry.selected {
 background-color: yellow;
}
div.toolsPane a.listEntry span.attributes {
	padding-left: 1em;
	float: right;
	color: grey;
}
'
]
