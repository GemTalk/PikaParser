"
PEG one or more ('+') clause
"
Class {
	#name : 'PikaOneOrMoreClause',
	#superclass : 'PikaSingleSubClauseClause',
	#category : 'Pika-Core-clause-nonterminal',
	#package : 'Pika-Core',
	#tag : 'clause-nonterminal'
}

{ #category : 'matching' }
PikaOneOrMoreClause >> determineWhetherCanMatchZeroChars [

	| oldCanMatchZeroChars |
	oldCanMatchZeroChars := canMatchZeroChars.
	self subClause canMatchZeroChars ifTrue: [ canMatchZeroChars := true ].
	^ oldCanMatchZeroChars not and: [ canMatchZeroChars ]
]

{ #category : 'matching' }
PikaOneOrMoreClause >> matchInput: inputString key: memoKey inTable: memoTable [

	| subClauseMemoKey subClauseMatch tailMatchMemoKey tailMatch |
	subClauseMemoKey := PikaMemoKey
		                    clause: self subClause
		                    startPos: memoKey startPos.
	subClauseMatch := memoTable bestMatchFor: subClauseMemoKey.
	subClauseMatch ifNil: [ ^ nil ].

	"Perform right-recursive match of the same OneOrMore clause, so that the memo table doesn't
    fill up with O(M^2) entries in the number of subclause matches M.
    If there are two or more matches, tailMatch will be non-null."
	tailMatchMemoKey := PikaMemoKey
		                    clause: self
		                    startPos: memoKey startPos + subClauseMatch len.
	tailMatch := memoTable bestMatchFor: tailMatchMemoKey.

	"Return a new (right-recursive) match"
	^ tailMatch
		  ifNil: [ "There is only one match => match has only one subclause"
			  PikaMatch
				  memoKey: memoKey
				  len: subClauseMatch len
				  subClauseMatches: { subClauseMatch }
				  input: inputString ]
		  ifNotNil: [ "There are two or more matches => match has two subclauses (head, tail)"
			  PikaMatch
				  memoKey: memoKey
				  len: subClauseMatch len + tailMatch len
				  subClauseMatches: {
						  subClauseMatch.
						  tailMatch }
				  input: inputString ]
]

{ #category : 'printing' }
PikaOneOrMoreClause >> printOn: aStream [

	printStringCached ifNil: [
		printStringCached := (self labeledSubClause
			                      printStringWithAstNodeLabel: self) , '+' ].
	aStream << printStringCached
]

{ #category : 'accessing' }
PikaOneOrMoreClause >> subClauseMatchesForMatch: aMatch [
	"Flatten right-recursive structure of OneOrMore parse subtree"

	| subClauseMatchesToUse match stop |
	subClauseMatchesToUse := OrderedCollection new.
	match := aMatch.
	stop := false.
	[ match subClauseMatches isEmpty | stop ] whileFalse: [ "Add head of right-recursive list to arraylist, paired with its AST node label, if present"
		subClauseMatchesToUse add:
			match memoKey clause labeledSubClauses first astNodeLabel
			-> match subClauseMatches first.
		match subClauseMatches size = 1
			ifTrue: [ "The last element of the right-recursive list will have a single element, i.e. (head),
						rather than two elements, i.e. (head, tail) -- 	see OneOrMore >> match"
				stop := true ]
			ifFalse: [ "Move to tail of list"
			match := match subClauseMatches second ] ].
	^ subClauseMatchesToUse
]
