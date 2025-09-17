Trait {
	#name : 'TPikaAstTools',
	#category : 'Pika-Parser',
	#package : 'Pika-Parser'
}

{ #category : 'private' }
TPikaAstTools >> visitAstNode: astNode [

	| selector modelNode |
	selector := (astNode label , ':') asSymbol.
	modelNode := self perform: selector with: astNode.
	self shouldRecordSourceLocations ifTrue: [
		self setSourceLocationOf: modelNode from: astNode ].
	^ modelNode
]
