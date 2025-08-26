"
A complete match of a {@link Clause} at a given start position.

The #input String is not used except for printing, where it is eases debugging.
"
Class {
	#name : 'PikaMatch',
	#superclass : 'Object',
	#instVars : [
		'memoKey',
		'len',
		'firstMatchingSubClauseIdx',
		'subClauseMatches',
		'input'
	],
	#category : 'Pika-Core-memotable',
	#package : 'Pika-Core',
	#tag : 'memotable'
}

{ #category : 'instance creation' }
PikaMatch class >> memoKey: aMemoKey [
	"Answer a new zero-length Match without subclauses"

	^ self memoKey: aMemoKey len: 0 input: ''
]

{ #category : 'instance creation' }
PikaMatch class >> memoKey: aMemoKey len: lengthInteger firstMatchingSubClauseIdx: firstMatchIndex subClauseMatches: subMatches input: inputString [
	"Answer a new Match"

	^ self new
		  memoKey: aMemoKey
		  len: lengthInteger
		  firstMatchingSubClauseIdx: firstMatchIndex
		  subClauseMatches: subMatches
		  input: inputString
]

{ #category : 'instance creation' }
PikaMatch class >> memoKey: aMemoKey len: lengthInteger input: input [
	"Answer a new Match of a terminal clause"

	^ self
		  memoKey: aMemoKey
		  len: lengthInteger
		  firstMatchingSubClauseIdx: 0
		  subClauseMatches: #(  )
		  input: input
]

{ #category : 'instance creation' }
PikaMatch class >> memoKey: aMemoKey len: lengthInteger subClauseMatches: subMatches input: inputString [
	"Answer a new Match of a nonterminal clause other than First"

	^ self
		  memoKey: aMemoKey
		  len: lengthInteger
		  firstMatchingSubClauseIdx: 0
		  subClauseMatches: subMatches
		  input: inputString
]

{ #category : 'accessing' }
PikaMatch >> getSubClauseMatches [
	"Get subclause matches. Automatically flattens the right-recursive structure of {@link OneOrMore} nodes,
	collecting the subclause matches into a single array of (AST node label, subclause match) tuples.
	return A list of tuples: (AST node label, subclause match)."

	subClauseMatches isEmpty ifTrue: [ "I am a terminal, or an empty placeholder match 
												returned by MemoTable lookUpBestMatch"
		^ OrderedCollection new ].

	^ memoKey clause subClauseMatchesForMatch: self
]

{ #category : 'testing' }
PikaMatch >> hasMatchedRules [ 
	"Answers true if the matched clause has any rules"
	^ memoKey hasMatchedRules
]

{ #category : 'accessing' }
PikaMatch >> input [

	^ input
]

{ #category : 'accessing' }
PikaMatch >> input: anObject [

	input := anObject
]

{ #category : 'testing' }
PikaMatch >> isBetterThan: otherMatch [
	"Compare this Match to another Match of the same Clause type and start position.
 Answer true if this Match is a better match than the other Match in the memo table."

	otherMatch == self ifTrue: [ ^ false ].
	^ len > otherMatch len
]

{ #category : 'accessing' }
PikaMatch >> len [

	^ len
]

{ #category : 'accessing' }
PikaMatch >> len: anObject [

	len := anObject
]

{ #category : 'accessing' }
PikaMatch >> memoKey [

	^ memoKey
]

{ #category : 'accessing' }
PikaMatch >> memoKey: anObject [

	memoKey := anObject
]

{ #category : 'initialization' }
PikaMatch >> memoKey: aMemoKey len: lengthInteger firstMatchingSubClauseIdx: firstMatchIndex subClauseMatches: subMatches input: inputString [

	memoKey := aMemoKey.
	len := lengthInteger.
	firstMatchingSubClauseIdx := firstMatchIndex.
	subClauseMatches := subMatches.
	input := inputString
]

{ #category : 'private' }
PikaMatch >> printLenOn: aStream [

	aStream << '+'.
	len printOn: aStream
]

{ #category : 'printing' }
PikaMatch >> printOn: aStream [

	| startPos |
	startPos := memoKey startPos.
	startPos printOn: aStream.
	self printLenOn: aStream.
	len > 0 ifTrue: [
		aStream space.
		(input copyFrom: startPos to: startPos + len - 1) printOn: aStream ].
	aStream << ' : '.
	memoKey printClauseOn: aStream
]

{ #category : 'printing' }
PikaMatch >> printStringWithRuleNames [

	| stream |
	stream := WriteStream on: String new.
	self printWithRuleNamesOn: stream.
	^ stream contents
]

{ #category : 'printing' }
PikaMatch >> printWithRuleNamesOn: aStream [

	self printWithoutClauseOn: aStream.
	memoKey printClauseWithRuleNamesOn: aStream
]

{ #category : 'private' }
PikaMatch >> printWithoutClauseOn: aStream [

	| startPos |
	startPos := memoKey startPos.
	startPos printOn: aStream.
	self printLenOn: aStream.
	len > 0 ifTrue: [
		aStream space.
		(input copyFrom: startPos to: startPos + len - 1) printOn: aStream ].
	aStream << ' : '
]

{ #category : 'accessing' }
PikaMatch >> startPos [

	^ memoKey startPos
]

{ #category : 'accessing' }
PikaMatch >> subClauseMatches [

	^ subClauseMatches
]

{ #category : 'double dispatching' }
PikaMatch >> subClauseMatchesForFirstClause [

	^ { ((memoKey clause labeledSubClauses at: firstMatchingSubClauseIdx)
		   astNodeLabel -> subClauseMatches first) }
]

{ #category : 'double dispatching' }
PikaMatch >> subClauseMatchesForOtherClauses [
	"Answer labeled subclause matches"

	| subClauses result |
	subClauses := memoKey clause labeledSubClauses.
	result := OrderedCollection new: subClauses size.
	subClauses size = subClauseMatches size ifFalse: [
		self error: 'bad assumption' ].
	subClauses
		with: subClauseMatches
		do: [ :clause :match | result add: clause astNodeLabel -> match ].
	^ result
]
