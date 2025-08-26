"
The NotFollowedBy (inverted lookahead) PEG operator.
"
Class {
	#name : 'PikaNotFollowedByClause',
	#superclass : 'PikaSingleSubClauseClause',
	#category : 'Pika-Core-clause-nonterminal',
	#package : 'Pika-Core',
	#tag : 'clause-nonterminal'
}

{ #category : 'matching' }
PikaNotFollowedByClause >> determineWhetherCanMatchZeroChars [

	canMatchZeroChars := true.
	self subClause canMatchZeroChars ifTrue: [
		self error:
			'Subclause always matches zero characters, so this clause will never match anything: '
			, self printString ].
	^ false
]

{ #category : 'testing' }
PikaNotFollowedByClause >> isNotFollowedByClause [

	^ true
]

{ #category : 'testing' }
PikaNotFollowedByClause >> makesSenseForFollowedBy [
	"Answer true if I make sense as the subClause of a FollowedBy clause"

	^ false
]

{ #category : 'as yet unclassified' }
PikaNotFollowedByClause >> matchInput: inputString key: memoKey inTable: memoTable [
	"If there is no valid subclause match, return a new zero-length match"

	| subClauseMemoKey subClauseMatch |
	subClauseMemoKey := PikaMemoKey
		                    clause: self subClause
		                    startPos: memoKey startPos.
	subClauseMatch := memoTable bestMatchFor: subClauseMemoKey.
	subClauseMatch ifNil: [ ^ PikaMatch memoKey: memoKey ].
	^ nil
]

{ #category : 'printing' }
PikaNotFollowedByClause >> printOn: aStream [

	printStringCached ifNil: [
		printStringCached := '!'
		                     ,
		                     (self labeledSubClause
			                      printStringWithAstNodeLabel: self) ].
	aStream << printStringCached
]
