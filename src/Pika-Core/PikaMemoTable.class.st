"
A memo entry for a specific {@link Clause} at a specific start position.

Instvars:

memoTable		<Dictionary>  	MemoKey -> Match 
									""A map from clause to startPos to a Match for the memo entry.""
		
grammar		<PikaGrammar>	The grammar being parsed
		
input			<String> 			The input string
						
numMatchObjectsCreated	<Integer>		
		
numMatchObjectsMemoized	<Integer>		The number of Match instances added to the memo table (some will be overwritten by later matches).
"
Class {
	#name : 'PikaMemoTable',
	#superclass : 'Object',
	#instVars : [
		'memoTable',
		'grammar',
		'input',
		'numMatchObjectsCreated',
		'numMatchObjectsMemoized'
	],
	#category : 'Pika-Core-memotable',
	#package : 'Pika-Core',
	#tag : 'memotable'
}

{ #category : 'instance creation' }
PikaMemoTable class >> forGrammar: aGrammar inputString: inputString [

	^ self new
		  grammar: aGrammar;
		  input: inputString;
		  yourself
]

{ #category : 'parsing' }
PikaMemoTable >> addMatch: newMatch withKey: memoKey priorityQueue: priorityQueue [
	"Add a new Match to the memo table, if the match is non-null. Schedule seed parent clauses for
	matching if the match is non-null or if the parent clause can match zero characters."

	| matchUpdated stdout |
	matchUpdated := false.
	stdout := nil. "lint"
	PikaGrammar debug ifTrue: [
		stdout := ZnCharacterWriteStream
			          on: (ZnBufferedWriteStream on: Stdio stdout)
			          encoding: 'utf8'.
		newMatch
			ifNotNil: [
				stdout << 'Matched: '.
				(input
					 copyFrom: memoKey startPos
					 to: memoKey startPos + newMatch len - 1) printOn: stdout.
				stdout space.
				newMatch printWithRuleNamesOn: stdout ]
			ifNil: [
				stdout << 'Failed to match: '.
				memoKey printWithRuleNamesOn: stdout ].
		stdout
			lf;
			flush ].
	newMatch ifNotNil: [
		| oldMatch |
		"Track memoization"
		numMatchObjectsCreated := numMatchObjectsCreated + 1.

		"Get the memo entry for memoKey if already present; if not, create a new entry"
		oldMatch := memoTable at: memoKey ifAbsent: [ nil ].

		"If there is no old match, or the new match is better than the old match"
		(oldMatch isNil or: [ newMatch isBetterThan: oldMatch ]) ifTrue: [ "Store the new match in the memo entry"
			memoTable at: memoKey put: newMatch.
			matchUpdated := true.

			"Track memoization"
			numMatchObjectsMemoized := numMatchObjectsMemoized + 1.
			PikaGrammar debug ifTrue: [
				stdout << 'Memoizing match: '.
				newMatch printWithRuleNamesOn: stdout.
				stdout
					lf;
					flush ] ] ].

	memoKey clause seedParentClauses do: [ :seedParentClause | "If there was a valid match, or if there was no match but the parent clause can match
		zero characters, schedule the parent clause for matching. (This is part of the strategy
		for minimizing the number of zero-length matches that are memoized.)"
		(matchUpdated or: [ seedParentClause canMatchZeroChars ]) ifTrue: [
			priorityQueue add: seedParentClause.
			PikaGrammar debug ifTrue: [
				stdout << '	Following seed parent clause: '.
				seedParentClause printWithRuleNamesOn: stdout.
				stdout
					lf;
					flush ] ] ]
]

{ #category : 'accessing' }
PikaMemoTable >> allMatchesForClause: clause [
	"Get the Match entries for all matches of this clause.
	Answer OrderedCollection of Matches, ordered by startPos"

		| matches |
		matches := OrderedCollection new.
		(self navigableMatchesForClause: clause) do: [ :ent | matches add: ent value ].
		^ matches
]

{ #category : 'accessing' }
PikaMemoTable >> allNavigableMatches [
	"Get all of my Match entries, indexed by clause then start position.
	Answer a Dictionary, clause -> (SkipList startPos -> match)"

	| clauseMap |
	clauseMap := Dictionary new.
	memoTable valuesDo: [ :match |
		| startPosMap |
		startPosMap := clauseMap
			               at: match memoKey clause
			               ifAbsentPut: [ SkipList new ].
		startPosMap add: match memoKey startPos -> match ].
	^ clauseMap
]

{ #category : 'accessing' }
PikaMemoTable >> allNonOverlappingMatches [
	"Get all nonoverlapping Match entries, indexed by clause then start position.
	Answer a Dictionary, clause -> (SkipList startPos -> match)"

	| nonOverlappingClauseMap |
	nonOverlappingClauseMap := Dictionary new.
	self allNavigableMatches associationsDo: [ :ent |
		| clause startPosMap prevEndPos nonOverlappingStartPosMap |
		clause := ent key.
		startPosMap := ent value.
		prevEndPos := 0.
		nonOverlappingStartPosMap := SkipList new.
		startPosMap do: [ :startPosEnt |
			| startPos |
			startPos := startPosEnt key.
			startPos >= prevEndPos ifTrue: [
				| match endPos |
				match := startPosEnt value.
				nonOverlappingStartPosMap at: startPos put: match.
				endPos := startPos + match len.
				prevEndPos := endPos ] ].
		nonOverlappingClauseMap at: clause put: nonOverlappingStartPosMap ].

	^ nonOverlappingClauseMap
]

{ #category : 'printing' }
PikaMemoTable >> ast [
	"Create and answer the top AST node"

	| topLevelRule ruleClause matches |
	topLevelRule := grammar topLevelRule.
	ruleClause := topLevelRule labeledClause clause.
	matches := self nonOverlappingMatchesForClause: ruleClause.
	matches size = 1 ifFalse: [
		self error: 'Expected exactly 1 top-level match, found '
			, matches size printString ].
	^ PikaAstNode
		  label: topLevelRule labeledClause astNodeLabel
		  match: matches first
		  input: input
]

{ #category : 'parsing' }
PikaMemoTable >> bestMatchFor: memoKey [
	"lookupBestMatch
	Find current best match in memo table (nil if there is no current best match)"

	memoTable
		at: memoKey
		ifPresent: [ :bestMatch | "If there is a current best match, return it"
			^ bestMatch ].
	memoKey clause isNotFollowedByClause ifTrue: [ "Need to match NotFollowedBy top-down"
		^ memoKey clause matchInput: input key: memoKey inTable: self ].

	memoKey clause canMatchZeroChars ifTrue: [ "If there is no match in the memo table for this clause, but this clause can match zero characters,
		then we need to return a new zero-length match to the parent clause. (This is part of the strategy
		for minimizing the number of zero-length matches that are memoized.)
		(N.B. this match will not have any subclause matches, which may be unexpected, so conversion of
		parse tree to AST should be robust to this.)"
		^ PikaMatch memoKey: memoKey ].
	"No match was found in the memo table"
	^ nil
]

{ #category : 'accessing' }
PikaMemoTable >> grammar [

	^ grammar
]

{ #category : 'accessing' }
PikaMemoTable >> grammar: anObject [

	grammar := anObject
]

{ #category : 'initialization' }
PikaMemoTable >> initialize [

	super initialize.
	memoTable := Dictionary new.
	numMatchObjectsCreated := numMatchObjectsMemoized := 0
]

{ #category : 'accessing' }
PikaMemoTable >> input [

	^ input
]

{ #category : 'accessing' }
PikaMemoTable >> input: anObject [

	input := anObject
]

{ #category : 'printing' }
PikaMemoTable >> matchedRuleReport [

	| matchesWithRules stream |
	matchesWithRules := SkipList sortBlock: [ :a :b | "Contains Matches"
		                    | asp bsp alen blen |
		                    asp := a startPos.
		                    bsp := b startPos.
		                    alen := a len.
		                    blen := b len.
		                    asp < bsp or: [ asp = bsp and: [ alen > blen ] ] ].
	matchesWithRules addAll:
		(memoTable select: [ :match | match hasMatchedRules ]).
	stream := WriteStream on: String new.
	matchesWithRules do: [ :match |
		match printWithRuleNamesOn: stream.
		stream lf ].
	^ stream contents
]

{ #category : 'accessing' }
PikaMemoTable >> navigableMatchesForClause: clause [
	"Get all Match entries for the given clause, indexed by start position.
	Answer a SkipList, startPos -> Match"

	| treeMap |
	treeMap := SkipList new.
	memoTable associationsDo: [ :ent |
		ent key clause = clause ifTrue: [
			treeMap at: ent key startPos put: ent value ] ].
	^ treeMap
]

{ #category : 'accessing' }
PikaMemoTable >> nonOverlappingMatchesForClause: clause [
	"Get the Match entries for all nonoverlapping matches of this clause, obtained by greedily matching
	from the beginning of the string, then looking for the next match after the end of the current match.
	Answer an OrderedCollection of Matches, ordered by startPos."

	| matches nonoverlappingMatches endPos |
	matches := self allMatchesForClause: clause.
	nonoverlappingMatches := OrderedCollection new.
	endPos := 0.
	matches do: [ :match |
		| startPos |
		startPos := match memoKey startPos.
		startPos >= endPos ifTrue: [
			endPos := startPos + match len.
			nonoverlappingMatches add: match ] ].
	^ nonoverlappingMatches
]

{ #category : 'accessing' }
PikaMemoTable >> numMatchObjectsCreated [

	^ numMatchObjectsCreated
]

{ #category : 'accessing' }
PikaMemoTable >> numMatchObjectsCreated: anObject [

	numMatchObjectsCreated := anObject
]

{ #category : 'accessing' }
PikaMemoTable >> numMatchObjectsMemoized [

	^ numMatchObjectsMemoized
]

{ #category : 'accessing' }
PikaMemoTable >> numMatchObjectsMemoized: anObject [

	numMatchObjectsMemoized := anObject
]

{ #category : 'accessing' }
PikaMemoTable >> syntaxErrorsForRuleNames: syntaxCoverageRuleNames [
	"Get any syntax errors in the parse, as a map from start position to a tuple, (end position, span of input
	string between start position and end position)."

	| parsedRanges unparsedRanges syntaxErrorSpans |
	"Find the range of characters spanned by matches for each of the coverageRuleNames"
	parsedRanges := PikaIntervalUnion new.
	syntaxCoverageRuleNames do: [ :coverageRuleName |
		| rule |
		rule := grammar ruleNamed: coverageRuleName.
		(self nonOverlappingMatchesForClause: rule labeledClause clause)
			do: [ :match |
				| startPos |
				startPos := match memoKey startPos.
				parsedRanges
					addRangeStartPos: startPos
					endPos: startPos + match len ] ].

	"Find the inverse of the parsed ranges -- these are the syntax errors"
	unparsedRanges := (parsedRanges
		                   invertStartPos: 1
		                   endPos: input size + 1) nonOverlappingRanges.

	"Extract the input string span for each unparsed range"
	syntaxErrorSpans := SkipList new.
	unparsedRanges associationsDo: [ :ent |
		| startPos endPos |
		startPos := ent key.
		endPos := ent value -> (input copyFrom: startPos to: ent value - 1).
		syntaxErrorSpans at: startPos put: endPos ].
	^ syntaxErrorSpans
]
