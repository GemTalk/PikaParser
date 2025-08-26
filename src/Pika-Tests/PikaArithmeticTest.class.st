Class {
	#name : 'PikaArithmeticTest',
	#superclass : 'TestCase',
	#instVars : [
		'grammar1',
		'grammar2',
		'grammar3',
		'grammar4',
		'grammar5'
	],
	#category : 'Pika-Tests',
	#package : 'Pika-Tests'
}

{ #category : 'grammars' }
PikaArithmeticTest >> grammar1 [

	grammar1 ifNil: [
		grammar1 := PikaMetaGrammar parse: self grammar1Source ].
	^ grammar1
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar1Source [
	"This grammar is written in CFG-style, and PEG parsers tend to have trouble with this.
	The Pika parser certainly does."

	^ '
	Program <- Statement+;
	Statement <- var:[a-z]+ "=" Sum ";";
	Sum <- add:(Sum "+" Term) / sub:(Sum "-" Term) / term:Term;
	Term <- num:[0-9]+ / sym:[a-z]+;
	'
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar2 [

	grammar2 ifNil: [
		grammar2 := PikaMetaGrammar parse: self grammar2Source ].
	^ grammar2
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar2Source [
	"R assoc (ambiguous)"

	^ '
	E <- sum:(E op:''+'' E) / N;
	N <- num:[0-9]+;
	'
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar3 [

	grammar3 ifNil: [
		grammar3 := PikaMetaGrammar parse: self grammar3Source ].
	^ grammar3
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar3Source [
	"L assoc.
	Also direct left recursion, but handled by Pika as desired."

	^ '
	E <- sum:(E op:''+'' N) / N;
	N <- num:[0-9]+;
	'
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar4 [

	grammar4 ifNil: [
		grammar4 := PikaMetaGrammar parse: self grammar4Source ].
	^ grammar4
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar4Source [
	"Pika parser can't parse this, because it memoizes at the level of individual clauses, not rules:
    https://github.com/lukehutch/pikaparser/issues/32#issuecomment-861895166"

	^ 'A <- a:(B / ''x''); B <- b:(A ''y'' / A ''x'');'
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar5 [

	grammar5 ifNil: [
		grammar5 := PikaMetaGrammar parse: self grammar5Source ].
	^ grammar5
]

{ #category : 'grammars' }
PikaArithmeticTest >> grammar5Source [

	^ 'A <- "a " B "monkeyapples"; B <- "million " / "million monkey";'
]

{ #category : 'tests' }
PikaArithmeticTest >> test1a [
	"Expected to fail"

	(self
		 tryParsing: 'x=a+b-c;'
		 withGrammar: self grammar1
		 topRuleName: 'Program'
		 syntaxCoverageRules: { 'Statement' }
		 shouldPass: false) yourself "inspect"
]

{ #category : 'tests' }
PikaArithmeticTest >> test1b [
	"Expected to succeed"

	(self
		 tryParsing: 'x=a-b+c;'
		 withGrammar: self grammar1
		 topRuleName: 'Program'
		 syntaxCoverageRules: { 'Statement' }
		 shouldPass: true) yourself "inspect"
]

{ #category : 'tests' }
PikaArithmeticTest >> test2 [
	"This produces a right-associative AST, equivalent to 0+(1+(2+3))"

	(self
		 tryParsing: '0+1+2+3'
		 withGrammar: self grammar2
		 topRuleName: 'E'
		 syntaxCoverageRules: { 'E'. 'N' }
		 shouldPass: true) yourself "inspect"
]

{ #category : 'tests' }
PikaArithmeticTest >> test3 [
	"This produces a left-associative AST, equivalent to ((0+1)+2)+3"

	(self
		 tryParsing: '0+1+2+3'
		 withGrammar: self grammar3
		 topRuleName: 'E'
		 syntaxCoverageRules: { 'E'. 'N' }
		 shouldPass: true) yourself "inspect"
]

{ #category : 'tests' }
PikaArithmeticTest >> test4 [
	"Fails due to limitations of the Pika algorithm in 
	parsing some kinds of recursion involving ordered choice."

	(self
		 tryParsing: 'xxyx'
		 withGrammar: self grammar4
		 topRuleName: 'A'
		 syntaxCoverageRules: { 'A'. 'B' }
		 shouldPass: false) yourself "inspect"
]

{ #category : 'tests' }
PikaArithmeticTest >> test5 [

	(self
		 tryParsing: 'a million monkeyapples'
		 withGrammar: self grammar5
		 topRuleName: 'A'
		 syntaxCoverageRules: { 'A'. 'B' }
		 shouldPass: true) yourself "inspect"
]

{ #category : 'support' }
PikaArithmeticTest >> tryParsing: input withGrammar: grammar topRuleName: topRuleName syntaxCoverageRules: syntaxCoverageRules [

	| memoTable stream syntaxErrors topRule topClause topMatches |
	memoTable := grammar parse: input.
	stream := WriteStream on: String new.
	"stream := ZnCharacterWriteStream on: Stdio stdout encoding: 'utf8'."
	PikaParserInfo
		printParseResultOfTopLevelRule: topRuleName
		on: stream
		memoTable: memoTable
		syntaxCoverageRuleNames: syntaxCoverageRules
		showAllMatches: false.
	syntaxErrors := memoTable syntaxErrorsForRuleNames:
		                syntaxCoverageRules.
	self assert: syntaxErrors isEmpty.
	topRule := grammar
		           ruleNamed: topRuleName
		           ifAbsent: [ self fail: 'No rule with top rule name' ].
	topClause := topRule labeledClause clause.
	topMatches := memoTable nonOverlappingMatchesForClause: topClause.
	self assert: topMatches size equals: 1.
	^ stream contents
]

{ #category : 'support' }
PikaArithmeticTest >> tryParsing: input withGrammar: grammar topRuleName: topRuleName syntaxCoverageRules: syntaxCoverageRules shouldPass: shouldPass [

	| memoTable stream syntaxErrors topRule topClause topMatches |
	memoTable := grammar parse: input.
	stream := WriteStream on: String new.
	"stream := ZnCharacterWriteStream on: Stdio stdout encoding: 'utf8'."
	PikaParserInfo
		printParseResultOfTopLevelRule: topRuleName
		on: stream
		memoTable: memoTable
		syntaxCoverageRuleNames: syntaxCoverageRules
		showAllMatches: false.
	syntaxErrors := memoTable syntaxErrorsForRuleNames:
		                syntaxCoverageRules.
	topRule := grammar
		           ruleNamed: topRuleName
		           ifAbsent: [ self fail: 'No rule with top rule name' ].
	shouldPass
		ifTrue: [ self assert: syntaxErrors isEmpty ]
		ifFalse: [ self deny: syntaxErrors isEmpty ].
	topClause := topRule labeledClause clause.
	topMatches := memoTable nonOverlappingMatchesForClause: topClause.
	self assert: topMatches size equals: (shouldPass
			 ifTrue: [ 1 ]
			 ifFalse: [ 0 ]).
	^ stream contents
]
