"
Placeholder clause used to add an AST node label to the provided subclause. AstNodeLabel clauses are
removed from the grammar before parsing, and the node label and subclause are moved into a LabeledClause
object for each subclause of a clause.
"
Class {
	#name : 'PikaAstNodeLabel',
	#superclass : 'PikaSingleSubClauseClause',
	#instVars : [
		'astNodeLabel'
	],
	#category : 'Pika-Core-clause',
	#package : 'Pika-Core',
	#tag : 'clause'
}

{ #category : 'instance creation' }
PikaAstNodeLabel class >> label: aString clause: aClause [

	| inst |
	inst := self withSubClauses: { aClause }.
	inst astNodeLabel: aString.
	^ inst
]

{ #category : 'accessing' }
PikaAstNodeLabel >> astNodeLabel: anObject [

	astNodeLabel := anObject
]

{ #category : 'matching' }
PikaAstNodeLabel >> determineWhetherCanMatchZeroChars [

	^ false
]

{ #category : 'testing' }
PikaAstNodeLabel >> isAstNodeLabel [

	^ true
]

{ #category : 'accessing' }
PikaAstNodeLabel >> label [

	^ astNodeLabel
]

{ #category : 'as yet unclassified' }
PikaAstNodeLabel >> matchInput: inputString key: memoKey inTable: memoTable [

	self error: self class name , ' node should not be in final grammar'
]

{ #category : 'printing' }
PikaAstNodeLabel >> printOn: aStream [

	printStringCached ifNil: [
		printStringCached := astNodeLabel , ':('
		                     , self labeledSubClause printString , ')' ].
	aStream << printStringCached
]
