Extension { #name : #OSSPipe }

{ #category : #'*GemstoneServerCockpit' }
OSSPipe >> end [
	"Signal in the stream, that we have no more data. Programms like
	sed or tee keep the stdin open, waiting for data. Simply closing this
	pipe did not end it, strangely!"
	self nextPut: Character end
]
