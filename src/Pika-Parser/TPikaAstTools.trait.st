Trait {
	#name : 'TPikaAstTools',
	#instVars : [
		'lineTable',
		'fileReference'
	],
	#category : 'Pika-Parser',
	#package : 'Pika-Parser'
}

{ #category : 'accessing' }
TPikaAstTools >> fileReference [

	^ fileReference
]

{ #category : 'accessing' }
TPikaAstTools >> fileReference: anObject [

	fileReference := anObject
]

{ #category : 'accessing' }
TPikaAstTools >> lineTable [

	^ lineTable
]

{ #category : 'accessing' }
TPikaAstTools >> lineTable: anObject [

	lineTable := anObject
]

{ #category : 'private' }
TPikaAstTools >> setSourceLocationOf: modelNode from: astNode [

	| sourceRef lineAndColumn startPos endPos |
	"If sourceReference already set by an inner AST node, keep that as being more accurate."
	modelNode sourceReference ifNotNil: [ ^ self ].
	startPos := astNode startPos.
	endPos := startPos + astNode len - 1.
	lineAndColumn := lineTable lineAndColumnForPosition: startPos.
	sourceRef := PikaSourceReference new
		             fileReference: fileReference;
		             lineNumber: lineAndColumn key;
		             columnNumber: lineAndColumn value;
		             sourceString: astNode input;
		             addRangeStartPos: startPos endPos: endPos;
		             yourself.
	modelNode sourceReference: sourceRef
]

{ #category : 'private' }
TPikaAstTools >> visitAstNode: astNode [

	| selector modelNode |
	selector := (astNode label , ':') asSymbol.
	modelNode := self perform: selector with: astNode.
	self shouldRecordSourceLocations ifTrue: [
		self setSourceLocationOf: modelNode from: astNode ].
	^ modelNode
]
