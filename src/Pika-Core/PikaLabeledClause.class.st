"
A container for grouping a subclause together with its AST node label.
"
Class {
	#name : 'PikaLabeledClause',
	#superclass : 'Object',
	#instVars : [
		'clause',
		'astNodeLabel'
	],
	#category : 'Pika-Core-ast',
	#package : 'Pika-Core',
	#tag : 'ast'
}

{ #category : 'instance creation' }
PikaLabeledClause class >> forClause: aClause labeled: astNodeLabel [

	^ self new
		  clause: aClause;
		  astNodeLabel: astNodeLabel;
		  yourself
]

{ #category : 'adding' }
PikaLabeledClause >> addSeedParentClause: aClause [

	clause addSeedParentClause: aClause
]

{ #category : 'accessing' }
PikaLabeledClause >> astNodeLabel [

	^ astNodeLabel
]

{ #category : 'accessing' }
PikaLabeledClause >> astNodeLabel: anObject [

	astNodeLabel := anObject
]

{ #category : 'testing' }
PikaLabeledClause >> canMatchZeroChars [

	^ clause canMatchZeroChars
]

{ #category : 'accessing' }
PikaLabeledClause >> clause [

	^ clause
]

{ #category : 'accessing' }
PikaLabeledClause >> clause: anObject [

	clause := anObject
]

{ #category : 'printing' }
PikaLabeledClause >> printOn: stream [

	self printWithAstNodeLabelParentClause: nil on: stream
]

{ #category : 'printing' }
PikaLabeledClause >> printStringWithAstNodeLabel: parentClause [

	| stream |
	stream := WriteStream on: String new.
	self printWithAstNodeLabelParentClause: parentClause on: stream.
	^ stream contents
]

{ #category : 'printing' }
PikaLabeledClause >> printWithAstNodeLabelParentClause: parentClause on: buf [
	"Print prepending any AST node label"

	| addParens |
	addParens := parentClause notNil and: [
		             PikaMetaGrammar
			             needToAddParensAroundSubClause: clause
			             parent: parentClause ].
	(astNodeLabel isNil and: [ addParens not ]) ifTrue: [
		^ clause printOn: buf ].
	astNodeLabel ifNotNil: [ :l |
		buf << l.
		buf << ':'.
		addParens := addParens
		             |
		             (PikaMetaGrammar
			              needToAddParensAroundAstNodeLabelOfClause: clause) ].
	addParens ifTrue: [ buf << '(' ].
	clause printOn: buf.
	addParens ifTrue: [ buf << ')' ]
]
