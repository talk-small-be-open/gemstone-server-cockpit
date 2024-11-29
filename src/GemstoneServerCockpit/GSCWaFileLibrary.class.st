Class {
	#name : 'GSCWaFileLibrary',
	#superclass : 'WAFileLibrary',
	#category : 'GemstoneServerCockpit-View',
	#package : 'GemstoneServerCockpit',
	#tag : 'View'
}

{ #category : 'as yet unclassified' }
GSCWaFileLibrary >> baseCss [
	^ '
body {
	padding-top: 20px;
	padding-bottom: 40px;
	background-color: white;
	font-family: monospace;
	padding: 2em;
}
input[type=text] {
	border: 1px solid black;
	width: 20em;
}
textarea { 
	border: 1px solid black;
}

input[type=submit], button, a.anchorButton { 
	border: 1px solid black;
	background: blue;
	color: white;
	padding: 3px;
	margin-top: 5px;
	margin-bottom: 5px;
	cursor: pointer;
}

pre { 
	white-space: pre;
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
table th {
	font-weight: bold;
}
a {
	text-decoration: none;
	color: blue;
}
a.anchorButton {
	display: inline-block;
}
a.anchorButton + a.anchorButton, a.anchorButton + input, input + a.anchorButton, input + input {
	margin-left: 5px;
}

h1, h2, h3 { 
	margin-top: 1em;
	margin-bottom: 0.5em;
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
'
]

{ #category : 'as yet unclassified' }
GSCWaFileLibrary >> resetCss [
	^ '
/***
    The new CSS reset - version 1.7.3 (last updated 7.8.2022)
    GitHub page: https://github.com/elad2412/the-new-css-reset
***/

/*
    Remove all the styles of the "User-Agent-Stylesheet", except for the ''display'' property
    - The "symbol *" part is to solve Firefox SVG sprite bug
 */
*:where(:not(html, iframe, canvas, img, svg, video, audio, input[type=checkbox]):not(svg *, symbol *)) {
    all: unset;
    display: revert;
}

/* Preferred box-sizing value */
*,
*::before,
*::after {
    box-sizing: border-box;
}

/* Reapply the pointer cursor for anchor tags */
a, button {
    cursor: revert;
}

/* Remove list styles (bullets/numbers) */
ol, ul, menu {
    list-style: none;
}

/* For images to not be able to exceed their container */
img {
    max-width: 100%;
}

/* removes spacing between cells in tables */
table {
    border-collapse: collapse;
}

/* Safari - solving issue when using user-select:none on the <body> text input doesn''t working */
input, textarea {
    -webkit-user-select: auto;
}

/* revert the ''white-space'' property for textarea elements on Safari */
textarea {
    white-space: revert;
}

/* minimum style to allow to style meter element */
meter {
    -webkit-appearance: revert;
    appearance: revert;
}

/* reset default text opacity of input placeholder */
::placeholder {
    color: unset;
}

/* fix the feature of ''hidden'' attribute.
   display:revert; revert to element instead of attribute */
:where([hidden]) {
    display: none;
}

/* revert for bug in Chromium browsers
   - fix for the content editable attribute will work properly.
   - webkit-user-select: auto; added for Safari in case of using user-select:none on wrapper element*/
:where([contenteditable]:not([contenteditable="false"])) {
    -moz-user-modify: read-write;
    -webkit-user-modify: read-write;
    overflow-wrap: break-word;
    -webkit-line-break: after-white-space;
    -webkit-user-select: auto;
}

/* apply back the draggable feature - exist only in Chromium and Safari */
:where([draggable="true"]) {
    -webkit-user-drag: element;
}


/* input[type=checkbox] { */
/* 		width: revert; */
/* 		height: revert; */
/* } */
'
]

{ #category : 'accessing' }
GSCWaFileLibrary >> selectorsToInclude [
	^#(resetCss baseCss styleCss)
]

{ #category : 'as yet unclassified' }
GSCWaFileLibrary >> styleCss [
	^ '
body {
 padding-top: 20px;
 padding-bottom: 40px;
 background-color: white;
	font-family: monospace;
}
div.horizontalScroll { 
	width: 100%;
	overflow-x: scroll;
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
div.subprocess pre.lastLogEntries { 
	max-height: 50vh;
	overflow-y: auto;
}
div.subprocess div.command {
	color: darkgreen;
	font-size: 120%;
	margin: 1em 0;
}
div.subprocess pre.lastLogEntries { 
	font-size: 75%;
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
div.lowerPane div.log { 
	margin-bottom: 1em;
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
div.toolsPane a.listEntry.main.selected {
 background-color: #ddd;
}
div.toolsPane a.listEntry span.attributes {
	padding-left: 1em;
	float: right;
	color: grey;
}

div.log pre { 
	font-size: 75%;
}

table.fileComparison { 
	font-size: 66%;
}
.error {
	color: red;
}
'
]
