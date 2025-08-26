"
The First (ordered choice) PEG operator.
"
Class {
	#name : 'PikaFirstClause',
	#superclass : 'PikaClause',
	#category : 'Pika-Core-clause-nonterminal',
	#package : 'Pika-Core',
	#tag : 'clause-nonterminal'
}

{ #category : 'instance creation' }
PikaFirstClause class >> withSubClauses: clauses [

	clauses size < 2 ifTrue: [
		^ self error: 'self name' , ' expects two or more subclauses' ].
	^ super withSubClauses: clauses
]

{ #category : 'matching' }
PikaFirstClause >> determineWhetherCanMatchZeroChars [
	"Up to one subclause of a First clause can match zero characters, and if present,
	the subclause that can match zero characters must be the last subclause."

	| oldCanMatchZeroChars |
	oldCanMatchZeroChars := canMatchZeroChars.
	1 to: labeledSubClauses size do: [ :i |
		| labeledSubClause |
		labeledSubClause := labeledSubClauses at: i.
		labeledSubClause canMatchZeroChars ifTrue: [
			canMatchZeroChars := true.
			i < labeledSubClauses size ifTrue: [
				self error:
					'Subclause ' , i printString , ' of ' , self class name
					,
					' can match zero characters, which means subsequent subclauses will never be matched: '
					, self printString ] ] ].
	^ oldCanMatchZeroChars not and: [ canMatchZeroChars ]
]

{ #category : 'testing' }
PikaFirstClause >> isFirst [

	^ true
]

{ #category : 'as yet unclassified' }
PikaFirstClause >> matchInput: inputString key: memoKey inTable: memoTable [

	1 to: labeledSubClauses size do: [ :subClauseIdx |
		| subClause subClauseMemoKey subClauseMatch |
		subClause := (labeledSubClauses at: subClauseIdx) clause.
		subClauseMemoKey := PikaMemoKey
			                    clause: subClause
			                    startPos: memoKey startPos.
		subClauseMatch := memoTable bestMatchFor: subClauseMemoKey.
		subClauseMatch ifNotNil: [
			^ PikaMatch
				  memoKey: memoKey
				  len: subClauseMatch len
				  firstMatchingSubClauseIdx: subClauseIdx
				  subClauseMatches: { subClauseMatch }
				  input: inputString ] ].
	^ nil
]

{ #category : 'printing' }
PikaFirstClause >> printOn: aStream [

	printStringCached ifNil: [
		| localStream |
		localStream := WriteStream on: String new.
		labeledSubClauses
			do: [ :each |
				each printWithAstNodeLabelParentClause: self on: localStream ]
			separatedBy: [ localStream << ' / ' ].
		printStringCached := localStream contents ].
	aStream << printStringCached
]

{ #category : 'accessing' }
PikaFirstClause >> subClauseMatchesForMatch: aMatch [
	"For First, pair the match with the AST node label from the subclause of idx firstMatchingSubclauseIdx"

	^ aMatch subClauseMatchesForFirstClause
]
