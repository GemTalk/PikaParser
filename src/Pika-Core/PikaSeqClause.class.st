"
The Seq (sequence) PEG operator.
"
Class {
	#name : 'PikaSeqClause',
	#superclass : 'PikaClause',
	#category : 'Pika-Core-clause-nonterminal',
	#package : 'Pika-Core',
	#tag : 'clause-nonterminal'
}

{ #category : 'instance creation' }
PikaSeqClause class >> withSubClauses: clauses [

	clauses size < 2 ifTrue: [
		self error: self name , ' expects 2 or more subclauses' ].
	^ super withSubClauses: clauses
]

{ #category : 'adding' }
PikaSeqClause >> addAsSeedParentClause [
	"All sub-clauses up to and including the first clause that matches one or more characters
	needs to seed its parent clause if there is a subclause match"

	| added |
	added := Set new.
	labeledSubClauses do: [ :lsc |
		| subClause |
		subClause := lsc clause.
		"Don't duplicate seed parent clauses in the subclause"
		(added includes: subClause) ifFalse: [
			added add: subClause.
			subClause seedParentClauses add: self ] ]
	
	"Could factor this into two methods so can early-out from the loop:
	if (!subClause.canMatchZeroChars) {
                // Don't need to any subsequent subclauses to seed this parent clause
                break;
            }
	"
]

{ #category : 'matching' }
PikaSeqClause >> determineWhetherCanMatchZeroChars [
	"For Seq, all subclauses must be able to match zero characters for the whole clause to
    be able to match zero characters"

	| oldCanMatchZeroChars |
	oldCanMatchZeroChars := canMatchZeroChars.
	canMatchZeroChars := true.
	labeledSubClauses do: [ :lsc |
		lsc clause canMatchZeroChars ifFalse: [ canMatchZeroChars := false ] ].
	^ oldCanMatchZeroChars not and: [ canMatchZeroChars ]
]

{ #category : 'testing' }
PikaSeqClause >> isSeq [
	"Answer true if I'm a sequence clause"

	^ true
]

{ #category : 'matching' }
PikaSeqClause >> matchInput: inputString key: memoKey inTable: memoTable [

	| subClauseMatches currStartPos subClauseMatch |
	currStartPos := memoKey startPos.
	subClauseMatches := labeledSubClauses collect: [ :lsc |
		                    | subClause subClauseMemoKey |
		                    subClause := lsc clause.
		                    subClauseMemoKey := PikaMemoKey
			                                        clause: subClause
			                                        startPos: currStartPos.
		                    subClauseMatch := memoTable bestMatchFor:
			                                      subClauseMemoKey.
		                    subClauseMatch ifNil: [ "Fail after first subclause fails to match"
			                    ^ nil ].
		                    currStartPos := currStartPos
		                                    + subClauseMatch len.
		                    subClauseMatch ].

	"All subclauses matched, so the Seq clause matches"
	^ PikaMatch
		  memoKey: memoKey
		  len: currStartPos - memoKey startPos
		  subClauseMatches: subClauseMatches
		  input: inputString
]

{ #category : 'printing' }
PikaSeqClause >> printOn: aStream [

	printStringCached ifNil: [
		| localStream |
		localStream := WriteStream on: String new.
		labeledSubClauses
			do: [ :lsc |
			lsc printWithAstNodeLabelParentClause: self on: localStream ]
			separatedBy: [ localStream << ' ' ].
		printStringCached := localStream contents ].
	aStream << printStringCached
]
