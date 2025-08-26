"
A node in the Abstract Syntax Tree (AST).
"
Class {
	#name : 'PikaAstNode',
	#superclass : 'Object',
	#instVars : [
		'label',
		'nodeType',
		'startPos',
		'len',
		'input',
		'children'
	],
	#category : 'Pika-Core-ast',
	#package : 'Pika-Core',
	#tag : 'ast'
}

{ #category : 'private' }
PikaAstNode class >> addNodeTree: parentAstNode match: parentMatch inputString: inputString [
	"Recursively convert a match node to an AST node."

	| subClauseMatchesToUse aPikaAstNode |
	aPikaAstNode := self new.
	subClauseMatchesToUse := parentMatch getSubClauseMatches.
	subClauseMatchesToUse do: [ :subClauseMatchEnt |
		| subClauseASTNodeLabel subClauseMatch |
		subClauseASTNodeLabel := subClauseMatchEnt key.
		subClauseMatch := subClauseMatchEnt value.
		subClauseASTNodeLabel
			ifNil: [ "Do not add an AST node for parse tree nodes that are not labeled; however, still need
                to recurse to their subclause matches"
				self
					addNodeTree: parentAstNode
					match: subClauseMatch
					inputString: inputString ]
			ifNotNil: [ "Create an AST node for any labeled sub-clauses"
				parentAstNode addChild: (aPikaAstNode class
						 label: subClauseASTNodeLabel
						 match: subClauseMatch
						 input: inputString) ] ]
]

{ #category : 'instance creation' }
PikaAstNode class >> label: label match: match input: input [

	| inst memoKey |
	memoKey := match memoKey.
	inst := self
		        label: label
		        nodeType: memoKey clause
		        startPos: memoKey startPos
		        len: match len
		        input: input.
	self addNodeTree: inst match: match inputString: input.
	^ inst
]

{ #category : 'instance creation' }
PikaAstNode class >> label: label nodeType: nodeType startPos: startPos len: len input: input [

	^ self new
		  label: label;
		  nodeType: nodeType;
		  startPos: startPos;
		  len: len;
		  input: input;
		  yourself
]

{ #category : 'adding' }
PikaAstNode >> addChild: child [

	children add: child
]

{ #category : 'accessing' }
PikaAstNode >> child: i [

	^ children at: i
]

{ #category : 'accessing' }
PikaAstNode >> children [

	^ children
]

{ #category : 'accessing' }
PikaAstNode >> firstChild [

	children isEmpty ifTrue: [ self error: 'No first child' ].
	^ children first
]

{ #category : 'initialization' }
PikaAstNode >> initialize [

	super initialize.
	children := OrderedCollection new
]

{ #category : 'accessing' }
PikaAstNode >> input: anObject [

	input := anObject
]

{ #category : 'accessing' }
PikaAstNode >> label [

	^ label
]

{ #category : 'accessing' }
PikaAstNode >> label: anObject [

	label := anObject
]

{ #category : 'accessing' }
PikaAstNode >> lastChild [

	children isEmpty ifTrue: [ self error: 'No children' ].
	^ children at: children size
]

{ #category : 'accessing' }
PikaAstNode >> len [

	^ len
]

{ #category : 'accessing' }
PikaAstNode >> len: anObject [

	len := anObject
]

{ #category : 'accessing' }
PikaAstNode >> nodeType: anObject [

	nodeType := anObject
]

{ #category : 'accessing' }
PikaAstNode >> onlyChild [

	children size = 1 ifFalse: [
		self error: 'Expected one child, got ' , children size printString ].
	^ children first
]

{ #category : 'printing' }
PikaAstNode >> printOn: aStream [

	PikaTreeUtils
		renderAstTreeView: self
		input: input
		indentStr: ''
		isLastChild: true
		on: aStream
]

{ #category : 'accessing' }
PikaAstNode >> secondChild [

	children size < 2 ifTrue: [ self error: 'No second child' ].
	^ children second
]

{ #category : 'accessing' }
PikaAstNode >> startPos [

	^ startPos
]

{ #category : 'accessing' }
PikaAstNode >> startPos: anObject [

	startPos := anObject
]

{ #category : 'accessing' }
PikaAstNode >> text [

	^ input copyFrom: startPos to: startPos + len - 1
]

{ #category : 'accessing' }
PikaAstNode >> thirdChild [

	children size < 3 ifTrue: [ self error: 'No third child' ].
	^ children third
]
