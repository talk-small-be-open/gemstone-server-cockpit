Class {
	#name : #GSCLogFileViewer,
	#superclass : #GSCTool,
	#instVars : [
		'filePath'
	],
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #accessing }
GSCLogFileViewer >> filePath [

	^ filePath
]

{ #category : #accessing }
GSCLogFileViewer >> filePath: anObject [

	filePath := self core realPathForFile: anObject
]

{ #category : #rendering }
GSCLogFileViewer >> renderBodyOn: html [

	| tail |
	
	tail := self core sudoReadCommand: 'tail -n 100' args: { filePath pathString }.
	
	html preformatted: tail.
]

{ #category : #accessing }
GSCLogFileViewer >> title [
	^ 'Log file'
]
