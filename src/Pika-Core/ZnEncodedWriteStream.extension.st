Extension { #name : 'ZnEncodedWriteStream' }

{ #category : '*Pika-Core' }
ZnEncodedWriteStream >> next: anInteger put: anObject [
	"Make anObject be the next anInteger number of objects accessible by the
	receiver. Answer anObject."

	anInteger timesRepeat: [ self nextPut: anObject ].
	^ anObject
]

{ #category : '*Pika-Core' }
ZnEncodedWriteStream >> space: anInteger [
	"Append anInteger space characters to the receiver."

	self next: anInteger put: Character space
]
