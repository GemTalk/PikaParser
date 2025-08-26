"
Utility methods for printing information about the result of a parse.
"
Class {
	#name : 'PikaParserInfo',
	#superclass : 'Object',
	#category : 'Pika-Core-utils',
	#package : 'Pika-Core',
	#tag : 'utils'
}

{ #category : 'private' }
PikaParserInfo class >> addSubsequentPartialMatchesOf: labeledSubClauses at: currStartPos to: matches memoTable: memoTable [

	2 to: labeledSubClauses size do: [ :i |
		| subClauseIMatch |
		subClauseIMatch := memoTable bestMatchFor: (PikaMemoKey
				                    clause: (labeledSubClauses at: i) clause
				                    startPos: currStartPos).
		subClauseIMatch ifNil: [ ^ self ].
		matches add: subClauseIMatch ]
]

{ #category : 'private' }
PikaParserInfo class >> findCycleDepthOfMatch: match cycleDictionary: cycleDepthToMatches [
	"Find the cycle depth of a given match (the maximum number of grammar cycles 
	in any path between the match and any descendant terminal match)."

	| cycleDepth matchesForDepth matchesForClauseIdx |
	cycleDepth := 0.
	match getSubClauseMatches do: [ :subClauseMatchEnt |
		| subClauseMatch subClauseIsInDifferentCycle subClauseMatchDepth |
		subClauseMatch := subClauseMatchEnt value.
		subClauseIsInDifferentCycle := match memoKey clause clauseIdx
		                               <=
		                               subClauseMatch memoKey clause
			                               clauseIdx.
		subClauseMatchDepth := self
			                       findCycleDepthOfMatch: subClauseMatch
			                       cycleDictionary: cycleDepthToMatches.
		cycleDepth := cycleDepth max: (subClauseIsInDifferentCycle
				               ifTrue: [ subClauseMatchDepth + 1 ]
				               ifFalse: [ subClauseMatchDepth ]) ].

	matchesForDepth := cycleDepthToMatches
		                   at: cycleDepth
		                   ifAbsentPut: [
		                   SkipList sortBlock: [ :a :b | a > b ] ].
	matchesForClauseIdx := matchesForDepth
		                       at: match memoKey clause clauseIdx
		                       ifAbsentPut: [ SkipList new ].

	matchesForClauseIdx at: match memoKey startPos put: match.
	^ cycleDepth
]

{ #category : 'printing' }
PikaParserInfo class >> memoTablePrintString: memoTable [

	| stream |
	stream := WriteStream on: String new.
	self printMemoTable: memoTable on: stream.
	^ stream contents
]

{ #category : 'public' }
PikaParserInfo class >> parseResultOfTopLevelRule: topLevelRuleName memoTable: memoTable syntaxCoverageRuleNames: syntaxCoverageRuleNames showAllMatches: showAllMatches [
	"Summarize a parsing result."

	| stream |
	stream := WriteStream on: String new.
	self
		printParseResultOfTopLevelRule: topLevelRuleName
		on: stream
		memoTable: memoTable
		syntaxCoverageRuleNames: syntaxCoverageRuleNames
		showAllMatches: showAllMatches.
	^ stream contents
]

{ #category : 'public' }
PikaParserInfo class >> parseTreeInMemoTableForm: memoTable [

	| stream |
	stream := WriteStream on: String new.
	self printParseTreeInMemoTableForm: memoTable on: stream.
	^ stream contents
]

{ #category : 'public' }
PikaParserInfo class >> printAstLabeled: astNodeLabel clause: clause memoTable: memoTable [
	"Print the AST for a given clause."

	| stdout |
	stdout := self stdout.
	self
		printAstLabeled: astNodeLabel
		on: stdout
		clause: clause
		memoTable: memoTable.
	stdout flush
]

{ #category : 'public' }
PikaParserInfo class >> printAstLabeled: astNodeLabel on: outStream clause: clause memoTable: memoTable [
	"Print the AST for a given clause."

	| matches |
	matches := memoTable nonOverlappingMatchesForClause: clause.
	matches do: [ :match |
		| ast |
		ast := PikaAstNode
			       label: astNodeLabel
			       match: match
			       input: memoTable input.
		ast printOn: outStream.
		outStream lf ]
]

{ #category : 'public' }
PikaParserInfo class >> printClausesOfGrammar: grammar [
	"Print all the clauses in a grammar."

	| stdout |
	stdout := self stdout.
	self printClausesOfGrammar: grammar on: stdout.
	stdout flush
]

{ #category : 'public' }
PikaParserInfo class >> printClausesOfGrammar: grammar on: outStream [
	"Print all the clauses in a grammar."

	| clauses |
	clauses := grammar allClauses.
	clauses size to: 1 by: -1 do: [ :i |
		| clause |
		clause := clauses at: i.
		i
			printOn: outStream
			base: 10
			length: 3
			padded: false.
		outStream << ' : '.
		clause printWithRuleNamesOn: outStream.
		outStream lf ]
]

{ #category : 'public' }
PikaParserInfo class >> printMatchesAndPartialMatchesForSeqClause: seqClause memoTable: memoTable [
	"Print matches in the memo table for a given Seq clause and its subclauses, 
	including partial matches of the Seq."

	| stdout |
	stdout := self stdout.
	self
		printMatchesAndPartialMatchesForSeqClause: seqClause
		on: stdout
		memoTable: memoTable.
	stdout flush
]

{ #category : 'public' }
PikaParserInfo class >> printMatchesAndPartialMatchesForSeqClause: seqClause on: outStream memoTable: memoTable [
	"Print matches in the memo table for a given Seq clause and its subclauses, 
	including partial matches of the Seq."

	| numSubClauses |
	numSubClauses := seqClause labeledSubClauses size.
	(memoTable allMatchesForClause:
		 seqClause labeledSubClauses first clause) do: [ :subClause0Match |
		| subClauseMatches currStartPos |
		subClauseMatches := OrderedCollection new.
		subClauseMatches add: subClause0Match.
		currStartPos := subClause0Match memoKey startPos
		                + subClause0Match len.
		self
			addSubsequentPartialMatchesOf: seqClause labeledSubClauses
			at: currStartPos
			to: subClauseMatches
			memoTable: memoTable.

		outStream
			lf;
			<< '====================================';
			lf;
			lf;
			<< 'Matched ';
			<< subClauseMatches size printString;
			<< ' out of ';
			<< numSubClauses printString;
			<< ' subclauses of clause ('.
		seqClause printOn: outStream.
		outStream
			<< ') at start pos ';
			<< subClause0Match memoKey startPos printString;
			lf;
			lf.
		1 to: subClauseMatches size do: [ :i |
			| subClauseMatch |
			subClauseMatch := subClauseMatches at: i.
			PikaTreeUtils
				renderTreeViewOfMatch: subClauseMatch
				on: outStream
				astNodeLabel: (seqClause labeledSubClauses at: i) astNodeLabel
				input: memoTable input
				indentStr: ''
				isLastChild: true.
			outStream lf ] ]
]

{ #category : 'public' }
PikaParserInfo class >> printMatchesAndSubClauseMatchesForClause: clause memoTable: memoTable [
	"Print matches in the memo table for a given clause and its subclauses."

	self
		printMatchesForClause: clause
		memoTable: memoTable
		showAllMatches: true.
	clause labeledSubClauses do: [ :subClause |
		self
			printMatchesForClause: subClause clause
			memoTable: memoTable
			showAllMatches: true ]
]

{ #category : 'public' }
PikaParserInfo class >> printMatchesForClause: clause memoTable: memoTable showAllMatches: showAllMatches [

	| stdout |
	stdout := self stdout.
	self
		printMatchesForClause: clause
		on: stdout
		memoTable: memoTable
		showAllMatches: showAllMatches.
	stdout flush
]

{ #category : 'public' }
PikaParserInfo class >> printMatchesForClause: clause on: outStream memoTable: memoTable showAllMatches: showAllMatches [

	| matches astNodeLabel prevEndPos |
	outStream
		<< '====================================';
		lf;
		lf.
	matches := memoTable allMatchesForClause: clause.
	matches ifEmpty: [
		outStream << 'No matches for '.
		clause printWithRuleNamesOn: outStream.
		outStream
			lf;
			lf.
		^ self ].
	outStream << 'Matches for '.
	clause printWithRuleNamesOn: outStream.
	outStream
		<< ' :';
		lf.

	"Get toplevel AST node label(s), if present"
	astNodeLabel := ''.
	clause rules do: [ :rule |
		rule labeledClause astNodeLabel ifNotNil: [ :label |
			astNodeLabel ifNotEmpty: [ astNodeLabel := astNodeLabel , ':' ].
			astNodeLabel := astNodeLabel , label ] ].
	prevEndPos := 0.
	matches do: [ :match |
		| overlapsPrevMatch newEndPos |
		"Indent matches that overlap with previous longest match"
		overlapsPrevMatch := match memoKey startPos < prevEndPos.
		(overlapsPrevMatch not or: [ showAllMatches ]) ifTrue: [
			| indent buf |
			indent := overlapsPrevMatch
				          ifTrue: [ '    ' ]
				          ifFalse: [ '' ].
			buf := WriteStream on: String new.
			PikaTreeUtils
				renderTreeViewOfMatch: match
				on: buf
				astNodeLabel:
				(astNodeLabel ifEmpty: [ nil ] ifNotEmpty: [ astNodeLabel ])
				input: memoTable input
				indentStr: indent
				isLastChild: true.
			outStream
				<< buf contents;
				lf ].
		newEndPos := match memoKey startPos + match len.
		prevEndPos := prevEndPos max: newEndPos ]
]

{ #category : 'printing' }
PikaParserInfo class >> printMemoTable: memoTable [

	| stdout |
	stdout := self stdout.
	self printMemoTable: memoTable on: stdout.
	stdout flush
]

{ #category : 'printing' }
PikaParserInfo class >> printMemoTable: memoTable on: outStream [

	| allClauses numClauses input inputSize streams strings marginWidth tableWidth nonOverlappingMatches row |
	allClauses := memoTable grammar allClauses.
	numClauses := allClauses size.
	input := memoTable input.
	inputSize := input size.
	streams := Array new: numClauses.
	marginWidth := 0.

	"Make line headers"
	1 to: numClauses do: [ :i |
		| stream clause index |
		stream := WriteStream on: String new.
		streams at: i put: stream.
		index := numClauses - i + 1.
		index
			printOn: stream
			base: 10
			length: 3
			padded: false.
		stream << ' : '.
		clause := allClauses at: index.
		clause isTerminal ifTrue: [ stream << '[terminal] ' ].
		clause canMatchZeroChars ifTrue: [ stream << '[canMatchZeroChars] ' ].
		clause printWithRuleNamesOn: stream.
		marginWidth := marginWidth max: stream position + 2 ].

	"Fill in empty line bodies"
	tableWidth := marginWidth + inputSize.
	streams do: [ :stream |
		[ stream position < marginWidth ] whileTrue: [ stream space ].
		[ stream position < tableWidth ] whileTrue: [ stream nextPut: $- ] ].

	"Replace streams with strings"
	strings := streams collect: [ :s | s contents ].

	nonOverlappingMatches := memoTable allNonOverlappingMatches.
	row := 1.
	allClauses reverseDo: [ :clause |
		| string |
		string := strings at: row.
		nonOverlappingMatches at: clause ifPresent: [ :matchesForClause |
			matchesForClause associationsDo: [ :matchEnt |
				| match matchStartPos matchEndPos |
				match := matchEnt value.
				matchStartPos := match memoKey startPos.
				matchEndPos := matchStartPos + match len.
				matchStartPos <= inputSize ifTrue: [
					string at: marginWidth + matchStartPos put: $# ].
				matchStartPos + 1 to: matchEndPos - 1 do: [ :j |
				j <= inputSize ifTrue: [ string at: marginWidth + j put: $= ] ] ] ].
		outStream
			<< string;
			lf.
		row := row + 1 ].

	"Print column numbers and input."
	outStream space: marginWidth.
	1 to: inputSize do: [ :i | outStream << (i \\ 10) printString ].
	outStream
		lf;
		space: marginWidth;
		<< (PikaStringUtils replaceNonAsciiIn: input);
		lf
]

{ #category : 'public' }
PikaParserInfo class >> printParseResultOfTopLevelRule: topLevelRuleName memoTable: memoTable syntaxCoverageRuleNames: syntaxCoverageRuleNames showAllMatches: showAllMatches [
	"Summarize a parsing result."

	| stdout bufStream utfStream |
	stdout := self stdout.
	bufStream := ZnBufferedWriteStream on: stdout.
	utfStream := ZnCharacterWriteStream on: bufStream encoding: 'utf8'.
	self
		printParseResultOfTopLevelRule: topLevelRuleName
		on: utfStream
		memoTable: memoTable
		syntaxCoverageRuleNames: syntaxCoverageRuleNames
		showAllMatches: showAllMatches.
	utfStream flush
]

{ #category : 'public' }
PikaParserInfo class >> printParseResultOfTopLevelRule: topLevelRuleName on: outStream memoTable: memoTable syntaxCoverageRuleNames: syntaxCoverageRuleNames showAllMatches: showAllMatches [
	"Summarize a parsing result."

	| syntaxErrors |
	outStream
		<< 'Clauses:';
		lf.
	self printClausesOfGrammar: memoTable grammar on: outStream.
	outStream
		lf;
		<< 'Memo Table:';
		lf.
	self printMemoTable: memoTable on: outStream.
	outStream
		lf;
		<< 'Match tree for rule ';
		<< topLevelRuleName;
		<< ':';
		lf.
	self printParseTreeInMemoTableForm: memoTable on: outStream.

	"Print all matches for each clause"
	memoTable grammar allClauses do: [ :clause |
		self
			printMatchesForClause: clause
			on: outStream
			memoTable: memoTable
			showAllMatches: showAllMatches ].

	memoTable grammar
		ruleNamed: topLevelRuleName
		ifPresent: [ :rule |
			| ruleClause |
			outStream
				<< '====================================';
				lf;
				lf;
				<< 'AST for rule "';
				<< topLevelRuleName;
				<< '":';
				lf.
			ruleClause := rule labeledClause clause.
			self
				printAstLabeled: topLevelRuleName
				on: outStream
				clause: ruleClause
				memoTable: memoTable ]
		ifAbsent: [
			outStream
				lf;
				<< 'Rule "';
				<< topLevelRuleName;
				<< '" does not exist';
				lf ].

	syntaxErrors := memoTable syntaxErrorsForRuleNames:
		                syntaxCoverageRuleNames.
	syntaxErrors ifNotEmpty: [ self printSyntaxErrors: syntaxErrors ].

	outStream
		lf;
		<< 'Num match objects created: ';
		<< memoTable numMatchObjectsCreated printString;
		lf;
		<< 'Num match objects memoized:  ';
		<< memoTable numMatchObjectsMemoized printString;
		lf;
		flush
]

{ #category : 'public' }
PikaParserInfo class >> printParseTreeInMemoTableForm: memoTable [

	self stdout
		<< (self parseTreeInMemoTableForm: memoTable);
		flush
]

{ #category : 'public' }
PikaParserInfo class >> printParseTreeInMemoTableForm: memoTable on: outStream [

	| cycleDepthToMatches inputSpanned nonOverlappingMatches maxCycleDepth matchesForRow clauseForRow rowLabel rowLabelMaxWidth emptyRowLabel edgeMarkers |
	memoTable grammar allClauses ifEmpty: [
		self error: 'Grammar is empty' ].

	"Map from cycle depth (sorted in decreasing order) -> clauseIdx -> startPos -> match"
	cycleDepthToMatches := SkipList sortBlock: [ :a :b | a > b ].

	"Input spanned by matches found so far"
	inputSpanned := PikaIntervalUnion new.

	"Get all nonoverlapping matches rules, top-down."
	nonOverlappingMatches := memoTable allNonOverlappingMatches.
	maxCycleDepth := 0.
	memoTable grammar allClauses reverseDo: [ :clause |
		nonOverlappingMatches
			at: clause
			ifPresent: [ :matchesForClause | "matchesForClause is a SkipList of startPos -> match"
				matchesForClause associationsDo: [ :matchEnt |
					| match matchStartPos matchEndPos |
					match := matchEnt value.
					matchStartPos := match memoKey startPos.
					matchEndPos := matchStartPos + match len.

					"Only add parse tree to chart if it doesn't overlap with input spanned by a higher-level match"
					(inputSpanned
						 doesRangeOverlapStart: matchStartPos
						 end: matchEndPos) ifFalse: [ "Pack matches into the lowest cycle they will fit into"
						| cycleDepth |
						cycleDepth := self
							              findCycleDepthOfMatch: match
							              cycleDictionary: cycleDepthToMatches.
						maxCycleDepth := maxCycleDepth max: cycleDepth.

						"Add the range spanned by this match"
						inputSpanned addRangeStartPos: matchStartPos endPos: matchEndPos ] ] ] ].

	"Assign matches to rows"
	matchesForRow := OrderedCollection new.
	clauseForRow := OrderedCollection new.
	cycleDepthToMatches do: [ :matchesForDepth |
		matchesForDepth associationsDo: [ :matchesForClauseIdxEnt |
			clauseForRow add:
				(memoTable grammar allClauses at: matchesForClauseIdxEnt key).
			matchesForRow add: matchesForClauseIdxEnt value ] ].

	"Set up row labels"
	rowLabel := Array new: clauseForRow size.
	rowLabelMaxWidth := 0.
	1 to: clauseForRow size do: [ :i |
		| clause rowLabelStream |
		clause := clauseForRow at: i.
		rowLabelStream := WriteStream on: String new.
		rowLabel at: i put: rowLabelStream.
		clause isTerminal ifTrue: [ rowLabelStream << '[terminal] ' ].
		clause canMatchZeroChars ifTrue: [
			rowLabelStream << '[canMatchZeroChars] ' ].
		clause printWithRuleNamesOn: rowLabelStream.
		rowLabelStream << '  '.
		rowLabelMaxWidth := rowLabelMaxWidth max: rowLabelStream position ].

	"Right-justify the row label"
	1 to: clauseForRow size do: [ :i |
		| clause clauseIdx rowLabelStream label |
		clause := clauseForRow at: i.
		clauseIdx := clause clauseIdx.
		rowLabelStream := rowLabel at: i.
		label := rowLabelStream contents.
		rowLabelStream
			reset;
			space: rowLabelMaxWidth - label size.
		clauseIdx
			printOn: rowLabelStream
			base: 10
			length: 3
			padded: false.
		rowLabelStream
			<< ' : ';
			<< label ].
	emptyRowLabel := String new: rowLabelMaxWidth + 6.
	emptyRowLabel atAllPut: Character space.
	edgeMarkers := WriteStream on: String new.
	edgeMarkers
		space;
		next: memoTable input size * 2 put: (Character codePoint: 16r2591).

	"Append one char for last column boundary, and two extra chars for zero-length matches past end of string"
	edgeMarkers << '   '.

	edgeMarkers space: rowLabelMaxWidth - edgeMarkers position.

	edgeMarkers := edgeMarkers contents.

	"Add tree structure to right of row label"
	1 to: clauseForRow size do: [ :row |
		| matches zeroLenMatchIdxs rowTreeChars |
		matches := matchesForRow at: row.
		rowTreeChars := edgeMarkers copy.
		zeroLenMatchIdxs := OrderedCollection new.
		matches associationsDo: [ :ent |
			| match startIdx endIdx |
			match := ent value.
			startIdx := match memoKey startPos.
			endIdx := startIdx + match len.
			endIdx = startIdx
				ifTrue: [ "Zero-length match" zeroLenMatchIdxs add: startIdx ]
				ifFalse: [ "Match consumes 1 or more characters"
					startIdx to: endIdx do: [ :i |
						| chrLeft |
						chrLeft := rowTreeChars at: i * 2 - 1.
						rowTreeChars at: i * 2 - 1 put: (i = startIdx
								 ifTrue: [
									 chrLeft = $│
										 ifTrue: [ $├ ]
										 ifFalse: [
											 chrLeft = $┤
												 ifTrue: [ $┼ ]
												 ifFalse: [
													 chrLeft = $┐
														 ifTrue: [ $┬ ]
														 ifFalse: [ $┌ ] ] ] ]
								 ifFalse: [
									 i = endIdx
										 ifTrue: [
											 chrLeft = $│
												 ifTrue: [ $┤ ]
												 ifFalse: [ $┐ ] ]
										 ifFalse: [ $─ ] ]).
						i < endIdx ifTrue: [ rowTreeChars at: i * 2 put: $─ ] ] ] ].
		outStream
			<< emptyRowLabel;
			<< rowTreeChars;
			lf.

		matches associationsDo: [ :ent |
			| match startIdx endIdx |
			match := ent value.
			startIdx := match memoKey startPos.
			endIdx := startIdx + match len.
			edgeMarkers
				at: startIdx * 2 - 1 put: $│;
				at: endIdx * 2 - 1 put: $│.
			startIdx * 2 to: endIdx - 1 * 2 do: [ :i |
				| c |
				c := edgeMarkers at: i.
				('░│' includes: c) ifTrue: [
					edgeMarkers at: i put: Character space ] ] ].
		rowTreeChars := edgeMarkers copy.
		matches associationsDo: [ :ent |
			| match startIdx endIdx |
			match := ent value.
			startIdx := match memoKey startPos.
			endIdx := startIdx + match len.
			startIdx to: endIdx - 1 do: [ :i |
				rowTreeChars
					at: i * 2
					put:
					(PikaStringUtils replaceNonAsciiForChar: (memoTable input at: i)) ] ].

		zeroLenMatchIdxs do: [ :zerLenMatchIdx |
			rowTreeChars at: zerLenMatchIdx * 2 put: $▮ ].
		outStream
			<< (rowLabel at: row) contents;
			<< rowTreeChars;
			lf ].

	"Print input index digits"
	outStream space: rowLabelMaxWidth + 7.
	1 to: memoTable input size do: [ :i |
		i \\ 10 printOn: outStream.
		outStream space ].
	outStream lf.

	"Print input string"
	outStream space: rowLabelMaxWidth + 7.
	memoTable input do: [ :c |
		outStream
			nextPut: (PikaStringUtils replaceNonAsciiForChar: c);
			space ].
	outStream lf
]

{ #category : 'public' }
PikaParserInfo class >> printSyntaxErrors: syntaxErrorMap [
	"Print syntax errors obtained from MemoTable>>getSyntaxErrors(String...)."

	"syntaxErrorsMap is a SkipList"

	| stream |
	syntaxErrorMap ifEmpty: [ ^ self ].
	stream := WriteStream on: String new.
	self printSyntaxErrors: syntaxErrorMap on: stream.
	^ stream contents
]

{ #category : 'public' }
PikaParserInfo class >> printSyntaxErrors: syntaxErrorMap on: stream [
	"Print syntax errors obtained from MemoTable>>getSyntaxErrors(String...)."

	"syntaxErrorsMap is a SkipList"

	syntaxErrorMap ifEmpty: [ ^ self ].
	stream
		lf;
		<< 'SYNTAX ERRORS:';
		lf;
		lf.
	syntaxErrorMap associationsDo: [ :ent |
		| startPos endPos syntaxErrorStr |
		startPos := ent key.
		endPos := ent value key.
		syntaxErrorStr := ent value value.
		"TODO: show line numbers"
		stream
			<< startPos printString;
			<< '+';
			<< (endPos - startPos) printString;
			<< ' : ';
			<< (PikaStringUtils replaceNonAsciiIn: syntaxErrorStr);
			lf;
			flush ]
]

{ #category : 'private' }
PikaParserInfo class >> stdout [

	^ ZnCharacterWriteStream
		  on: (ZnBufferedWriteStream on: Stdio stdout)
		  encoding: 'utf8'
]
