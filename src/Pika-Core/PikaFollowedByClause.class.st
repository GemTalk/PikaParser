"
The FollowedBy (lookahead) PEG operator
"
Class {
	#name : 'PikaFollowedByClause',
	#superclass : 'PikaSingleSubClauseClause',
	#category : 'Pika-Core-clause-nonterminal',
	#package : 'Pika-Core',
	#tag : 'clause-nonterminal'
}

{ #category : 'matching' }
PikaFollowedByClause >> determineWhetherCanMatchZeroChars [
	"Don't set canMatchZeroChars to true, because FollowedBy will only match if its subclause
	consumes at least one matching character"

	self subClause canMatchZeroChars ifTrue: [
		self error:
			'Subclause always matches zero characters, so this clause has no effect: '
			, self printString ].
	^ false
]

{ #category : 'testing' }
PikaFollowedByClause >> makesSenseForFollowedBy [
	"Answer true if I make sense as the subClause of a FollowedBy clause"

	^ false
]

{ #category : 'testing' }
PikaFollowedByClause >> makesSenseForNotFollowedBy [
	"Answer true if I make sense as the subClause of a NotFollowedBy clause"

	^ false
]

{ #category : 'as yet unclassified' }
PikaFollowedByClause >> matchInput: inputString key: memoKey inTable: memoTable [

	| subClauseMemoKey subClauseMatch |
	subClauseMemoKey := PikaMemoKey
		                    clause: self subClause
		                    startPos: memoKey startPos.
	subClauseMatch := memoTable bestMatchFor: subClauseMemoKey.
	subClauseMatch ifNotNil: [ ^ PikaMatch memoKey: memoKey ].
	^ nil
]

{ #category : 'printing' }
PikaFollowedByClause >> printOn: aStream [

	printStringCached ifNil: [
		printStringCached := '&' , self labeledSubClause printString ].
	aStream << printStringCached
]
