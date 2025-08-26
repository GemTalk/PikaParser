Extension { #name : 'AbstractBinaryFileStream' }

{ #category : '*Pika-Core' }
AbstractBinaryFileStream >> space [

	self nextPut: Character space asInteger
]

{ #category : '*Pika-Core' }
AbstractBinaryFileStream >> space: anInteger [
	"Append anInteger space characters to the receiver."

	self next: anInteger put: Character space
]
