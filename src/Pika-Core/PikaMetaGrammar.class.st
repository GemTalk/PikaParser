"
A ""meta-grammar"" that produces a runtime parser generator, allowing a grammar to be defined using ASCII notation.
"
Class {
	#name : 'PikaMetaGrammar',
	#superclass : 'Object',
	#classInstVars : [
		'clauseTypeToPrecedence',
		'grammar'
	],
	#category : 'Pika-Core-grammar',
	#package : 'Pika-Core',
	#tag : 'grammar'
}

{ #category : 'accessing' }
PikaMetaGrammar class >> clauseTypeToPrecedence [

	^ clauseTypeToPrecedence ifNil: [
		  clauseTypeToPrecedence := Dictionary new.
		  clauseTypeToPrecedence
			  at: PikaTerminalClause put: 7;
			  at: PikaRuleRef put: 7;
			  "Treat RuleRef as having the same precedence as a terminal for string interning purposes"
			  at: PikaOneOrMoreClause
			  put: 6;
			  "ZeroOrMore is not present in the final grammar, so it is skipped here"
			  at: PikaNotFollowedByClause
			  put: 5;
			  at: PikaFollowedByClause put: 5;
			  "Optional is not present in final grammar, so it is skipped here"
			  at: PikaAstNodeLabel
			  put: 3;
			  at: PikaSeqClause put: 2;
			  at: PikaFirstClause put: 1;
			  yourself ]
]

{ #category : 'private' }
PikaMetaGrammar class >> expectOneClauseIn: clauses forAst: astNode [
	"Expect just a single clause in the list of clauses, and return it, or throw an exception if the length of the
	list of clauses is not 1."

	clauses size = 1 ifFalse: [
		^ self error:
			  'Expected one subclause, got ' , clauses size printString , ': '
			  , astNode printString ].
	^ clauses first
]

{ #category : 'accessing' }
PikaMetaGrammar class >> grammar [

	^ grammar ifNil: [ self initializeGrammar ]
]

{ #category : 'initialization' }
PikaMetaGrammar class >> initializeGrammar [
	"PikaMetaGrammar initializeGrammar"

	| cf rules wsc |
	cf := PikaClauseFactory.
	wsc := cf ruleRefTo: 'WSC'.
	rules := {
		         (cf ruleNamed: 'GRAMMAR' clause: (cf seq: {
					           cf start.
					           wsc.
					           (cf oneOrMore: (cf ruleRefTo: 'RULE')) })).
		         (cf
			          ruleNamed: 'RULE'
			          clause: (cf astLabeled: 'RuleAST' clause: (cf seq: {
							            (cf ruleRefTo: 'IDENT').
							            wsc.
							            (cf optional: (cf ruleRefTo: 'PREC')).
							            (cf str: '<-').
							            wsc.
							            (cf ruleRefTo: 'CLAUSE').
							            wsc.
							            (cf cInStr: ';').
							            wsc }))).
		         "Define precedence order for clause sequences"

		         "Parens"
		         (cf
			          ruleNamed: 'CLAUSE'
			          precedence: 8
			          associativity: nil
			          clause: (cf seq: {
						           (cf cInStr: '(').
						           wsc.
						           (cf ruleRefTo: 'CLAUSE').
						           wsc.
						           (cf cInStr: ')') })).

		         "Terminals"
		         (cf
			          ruleNamed: 'CLAUSE'
			          precedence: 7
			          associativity: nil
			          clause: (cf first: {
						           (cf ruleRefTo: 'IDENT').
						           (cf ruleRefTo: 'QUOTED_STR').
						           (cf ruleRefTo: 'CHARSET').
						           (cf ruleRefTo: 'ANYTHING').
						           (cf ruleRefTo: 'NOTHING').
						           (cf ruleRefTo: 'START') })).

		         "OneOrMore / ZeroOrMore"
		         (cf
			          ruleNamed: 'CLAUSE'
			          precedence: 6
			          associativity: nil
			          clause: (cf first: {
						           (cf seq: {
								            (cf
									             astLabeled: 'OneOrMoreAST'
									             clause: (cf ruleRefTo: 'CLAUSE')).
								            wsc.
								            (cf cInStr: '+') }).
						           (cf seq: {
								            (cf
									             astLabeled: 'ZeroOrMoreAST'
									             clause: (cf ruleRefTo: 'CLAUSE')).
								            wsc.
								            (cf cInStr: '*') }) })).

		         "FollowedBy / NotFollowedBy"
		         (cf
			          ruleNamed: 'CLAUSE'
			          precedence: 5
			          associativity: nil
			          clause: (cf first: {
						           (cf seq: {
								            (cf cInStr: '&').
								            (cf
									             astLabeled: 'FollowedByAST'
									             clause: (cf ruleRefTo: 'CLAUSE')) }).
						           (cf seq: {
								            (cf cInStr: '!').
								            (cf
									             astLabeled: 'NotFollowedByAST'
									             clause: (cf ruleRefTo: 'CLAUSE')) }) })).

		         "Optional"
		         (cf
			          ruleNamed: 'CLAUSE'
			          precedence: 4
			          associativity: nil
			          clause: (cf seq: {
						           (cf
							            astLabeled: 'OptionalAST'
							            clause: (cf ruleRefTo: 'CLAUSE')).
						           wsc.
						           (cf cInStr: '?') })).

		         "ASTNodeLabel"
		         (cf
			          ruleNamed: 'CLAUSE'
			          precedence: 3
			          associativity: nil
			          clause: (cf astLabeled: 'LabelAST' clause: (cf seq: {
							            (cf
								             astLabeled: 'LabelNameAST'
								             clause: (cf ruleRefTo: 'IDENT')).
							            wsc.
							            (cf cInStr: ':').
							            wsc.
							            (cf
								             astLabeled: 'LabelClauseAST'
								             clause: (cf ruleRefTo: 'CLAUSE')).
							            wsc }))).

		         "Seq"
		         (cf
			          ruleNamed: 'CLAUSE'
			          precedence: 2
			          associativity: nil
			          clause: (cf astLabeled: 'SeqAST' clause: (cf seq: {
							            (cf ruleRefTo: 'CLAUSE').
							            wsc.
							            (cf oneOrMore: (cf seq: {
										              (cf ruleRefTo: 'CLAUSE').
										              wsc })) }))).

		         "First"
		         (cf
			          ruleNamed: 'CLAUSE'
			          precedence: 1
			          associativity: nil
			          clause: (cf astLabeled: 'FirstAST' clause: (cf seq: {
							            (cf ruleRefTo: 'CLAUSE').
							            wsc.
							            (cf oneOrMore: (cf seq: {
										              (cf cInStr: '/').
										              wsc.
										              (cf ruleRefTo: 'CLAUSE').
										              wsc })) }))).

		         "Whitespace or comment"
		         (cf ruleNamed: 'WSC' clause: (cf zeroOrMore: (cf first: {
						            (cf cInStr: {
								             Character space.
								             Character lf.
								             Character cr.
								             Character tab }).
						            (cf ruleRefTo: 'COMMENT') }))).

		         "Comment"
		         (cf ruleNamed: 'COMMENT' clause: (cf seq: {
					           (cf cInStr: '#').
					           (cf zeroOrMore: (cf cSets: { (cf cInStr: {
									              Character lf.
									              Character cr }) }) invert) })).

		         "Identifier"
		         (cf
			          ruleNamed: 'IDENT'
			          clause: (cf astLabeled: 'IdentAST' clause: (cf seq: {
							            (cf ruleRefTo: 'NAME_CHAR').
							            (cf zeroOrMore: (cf first: {
										              (cf ruleRefTo: 'NAME_CHAR').
										              (cf cRangeFrom: $0 to: $9) })) }))).

		         "Number"
		         (cf
			          ruleNamed: 'NUM'
			          clause: (cf oneOrMore: (cf cRangeFrom: $0 to: $9))).

		         "Name character"
		         (cf ruleNamed: 'NAME_CHAR' clause: (cf cSets: {
					           (cf cRangeFrom: $a to: $z).
					           (cf cRangeFrom: $A to: $Z).
					           (cf cInStr: '_-') })).

		         "Precedence and optional associativity modifiers for rule name"
		         (cf ruleNamed: 'PREC' clause: (cf seq: {
					           (cf cInStr: '[').
					           wsc.
					           (cf
						            astLabeled: 'PrecAST'
						            clause: (cf ruleRefTo: 'NUM')).
					           wsc.
					           (cf optional: (cf seq: {
								             (cf cInStr: ',').
								             wsc.
								             (cf first: {
										              (cf
											               astLabeled: 'RAssocAST'
											               clause: (cf first: {
														                (cf cInStr: 'r').
														                (cf cInStr: 'R') })).
										              (cf
											               astLabeled: 'LAssocAST'
											               clause: (cf first: {
														                (cf cInStr: 'l').
														                (cf cInStr: 'L') })) }).
								             wsc })).
					           (cf cInStr: ']').
					           wsc })).

		         "Character set"
		         (cf ruleNamed: 'CHARSET' clause: (cf first: {
					           (cf seq: {
							            (cf cInStr: '''').
							            (cf
								             astLabeled: 'SingleQuotedCharAST'
								             clause: (cf ruleRefTo: 'SINGLE_QUOTED_CHAR')).
							            (cf cInStr: '''') }).
					           (cf seq: {
							            (cf cInStr: '[').
							            (cf astLabeled: 'CharRangeAST' clause: (cf seq: {
										              (cf optional: (cf cInStr: '^')).
										              (cf oneOrMore: (cf first: {
													                (cf ruleRefTo: 'CHAR_RANGE').
													                (cf ruleRefTo: 'CHAR_RANGE_CHAR') })) })).
							            (cf cInStr: ']') }) })).

		         "Single quoted character"
		         (cf ruleNamed: 'SINGLE_QUOTED_CHAR' clause: (cf first: {
					           (cf ruleRefTo: 'ESCAPED_CTRL_CHAR').
					           (cf cSets: { (cf cInStr: '\') }) invert
					           "TODO: replace invert() with NotFollowedBy" })).

		         "Char range"
		         (cf ruleNamed: 'CHAR_RANGE' clause: (cf seq: {
					           (cf ruleRefTo: 'CHAR_RANGE_CHAR').
					           (cf cInStr: '-').
					           (cf ruleRefTo: 'CHAR_RANGE_CHAR') })).

		         "Char range character"
		         (cf ruleNamed: 'CHAR_RANGE_CHAR' clause: (cf first: {
					           (cf cSets: { (cf cInStr: '\]') }) invert.
					           (cf ruleRefTo: 'ESCAPED_CTRL_CHAR').
					           (cf str: '\-').
					           (cf str: '\\').
					           (cf str: '\]').
					           (cf str: '\^') })).

		         "Quoted string"
		         (cf ruleNamed: 'QUOTED_STR' clause: (cf seq: {
					           (cf cInStr: '"').
					           (cf
						            astLabeled: 'QuotedStringAST'
						            clause:
						            (cf zeroOrMore: (cf ruleRefTo: 'STR_QUOTED_CHAR'))).
					           (cf cInStr: '"') })).

		         "Character within quoted string"
		         (cf ruleNamed: 'STR_QUOTED_CHAR' clause: (cf first: {
					           (cf ruleRefTo: 'ESCAPED_CTRL_CHAR').
					           (cf cSets: { (cf cInStr: '"') }) invert })).

		         "Hex digit"
		         (cf ruleNamed: 'Hex' clause: (cf cSets: {
					           (cf cRangeFrom: $0 to: $9).
					           (cf cRangeFrom: $a to: $f).
					           (cf cRangeFrom: $A to: $F) })).

		         "Escaped control character"
		         (cf ruleNamed: 'ESCAPED_CTRL_CHAR' clause: (cf first: {
					           (cf str: '\t').
					           (cf str: '\b').
					           (cf str: '\n').
					           (cf str: '\r').
					           (cf str: '\f').
					           (cf str: '\''').
					           (cf str: '\"').
					           (cf str: '\\').
					           (cf seq: {
							            (cf str: '\u').
							            (cf ruleRefTo: 'Hex').
							            (cf ruleRefTo: 'Hex').
							            (cf ruleRefTo: 'Hex').
							            (cf ruleRefTo: 'Hex') }) })).

		         "Match any character"
		         (cf
			          ruleNamed: 'ANYTHING'
			          clause:
			          (cf astLabeled: 'AnythingAST' clause: (cf cInStr: '.'))).

		         "Nothing (empty string match)"
		         (cf
			          ruleNamed: 'NOTHING'
			          clause: (cf astLabeled: 'NothingAST' clause: (cf seq: {
							            (cf cInStr: '(').
							            wsc.
							            (cf cInStr: ')') }))).

		         "Match start position"
		         (cf
			          ruleNamed: 'START'
			          clause:
			          (cf astLabeled: 'StartAST' clause: (cf cInStr: '^'))) }.
	grammar := PikaGrammar forRules: rules.
	^ grammar
]

{ #category : 'testing' }
PikaMetaGrammar class >> needToAddParensAroundAstNodeLabelOfClause: subClause [
	"Return true if subclause has lower precedence than an AST node label"

	| cttp astNodeLabelPrec subClausePrec |
	cttp := self clauseTypeToPrecedence.
	astNodeLabelPrec := cttp at: PikaAstNodeLabel.
	subClausePrec := subClause isTerminal
		                 ifTrue: [ cttp at: PikaTerminalClause ]
		                 ifFalse: [ cttp at: subClause class ].
	^ subClausePrec < astNodeLabelPrec
]

{ #category : 'testing' }
PikaMetaGrammar class >> needToAddParensAroundSubClause: subClause parent: parentClause [
	"Return true if subClause precedence is less than or equal to parentClause precedence (or if subclause is a
	Seq clause and parentClause is a First clause, for clarity, even though parens are not needed
	because Seq has higher precedence)."

	| cttp clausePrec subClausePrec |
	cttp := self clauseTypeToPrecedence.
	clausePrec := parentClause isTerminal
		              ifTrue: [
		              cttp at: PikaTerminalClause ]
		              ifFalse: [
		              cttp at: parentClause class ].
	subClausePrec := subClause isTerminal
		                 ifTrue: [
		                 cttp at: PikaTerminalClause ]
		                 ifFalse: [
		                 cttp at: subClause class ].
	"Always parenthesize Seq inside First for clarity, even though Seq has higher precedence"
	^ (parentClause isFirst and: [ subClause isSeq ]) or: [
		  subClausePrec <= clausePrec ]
]

{ #category : 'parsing' }
PikaMetaGrammar class >> parse: input [
	"Parse a grammar description in an input string, returning a new Grammar object."

	| stdout memoTable syntaxErrors topLevelRule topLevelRuleASTNodeLabel topLevelMatch topLevelAstNode topLevelMatches rules |
	stdout := ZnCharacterWriteStream
		          on: (ZnBufferedWriteStream on: Stdio stdout)
		          encoding: 'utf8'.
	memoTable := self grammar parse: input.

	"ParserInfo.printParseResult(""GRAMMAR"", memoTable, new String[] { ""GRAMMAR"", ""RULE"", ""CLAUSE[1]"" },
        //				/* showAllMatches = */ false);
        //
        //		System.out.println(""\nParsed meta-grammar:"");
        //		for (var clause : MetaGrammar.grammar.allClauses) {
        //			System.out.println(""    "" + clause.toStringWithRuleNames());
        //		}"

	syntaxErrors := memoTable syntaxErrorsForRuleNames: {
			                'GRAMMAR'.
			                'RULE'.
			                ('CLAUSE' , '['
			                 ,
			                 (self clauseTypeToPrecedence at: PikaFirstClause)
				                 printString , ']') }.
	syntaxErrors ifNotEmpty: [
		| errorDescription |
		errorDescription := PikaParserInfo printSyntaxErrors: syntaxErrors.
		RuntimeSyntaxError signalSyntaxError: errorDescription ].

	topLevelRule := grammar ruleNamed: 'GRAMMAR'.
	topLevelRuleASTNodeLabel := topLevelRule labeledClause astNodeLabel.
	topLevelRuleASTNodeLabel ifNil: [
		topLevelRuleASTNodeLabel := '<root>' ].
	topLevelMatches := grammar
		                   nonOverlappingMatchesForRule: 'GRAMMAR'
		                   memoTable: memoTable.
	topLevelMatches
		ifEmpty: [ self error: 'Toplevel rule "GRAMMAR" did not match' ]
		ifNotEmpty: [
			topLevelMatches size > 1 ifTrue: [
				stdout
					lf;
					<< 'Multiple toplevel matches:';
					lf.
				topLevelMatches do: [ :tlMatch |
					| tlAstNode |
					tlAstNode := PikaAstNode
						             label: topLevelRuleASTNodeLabel
						             match: tlMatch
						             input: input.
					tlAstNode printOn: stdout.
					stdout lf ].
				stdout flush.
				self error: 'Stopping - See stdout' ] ].
	topLevelMatch := topLevelMatches first.

	"TreeUtils.printTreeView(topLevelMatch, input);"

	topLevelAstNode := PikaAstNode
		                   label: topLevelRuleASTNodeLabel
		                   match: topLevelMatch
		                   input: input.

	"System.out.println(topLevelASTNode);"

	"memoTable inspect."

	rules := OrderedCollection new.
	topLevelAstNode children do: [ :astNode |
		| rule |
		astNode label = 'RuleAST' ifFalse: [ self error: 'Wrong node type' ].
		rule := self parseRule: astNode.
		rules add: rule ].
	^ PikaGrammar forRules: rules
]

{ #category : 'private' }
PikaMetaGrammar class >> parseAstNode: astNode [
	"Recursively parse a single AST node."

	| cf label children |
	cf := PikaClauseFactory.
	label := astNode label.
	children := astNode children.

	label = 'SeqAST' ifTrue: [ ^ cf seq: (self parseAstNodes: children) ].
	label = 'FirstAST' ifTrue: [
		^ cf first: (self parseAstNodes: children) ].
	label = 'OneOrMoreAST' ifTrue: [
		^ cf oneOrMore: (self
				   expectOneClauseIn: (self parseAstNodes: children)
				   forAst: astNode) ].
	label = 'ZeroOrMoreAST' ifTrue: [
		^ cf zeroOrMore: (self
				   expectOneClauseIn: (self parseAstNodes: children)
				   forAst: astNode) ].
	label = 'OptionalAST' ifTrue: [
		^ cf optional: (self
				   expectOneClauseIn: (self parseAstNodes: children)
				   forAst: astNode) ].
	label = 'FollowedByAST' ifTrue: [
		^ cf followedBy: (self
				   expectOneClauseIn: (self parseAstNodes: children)
				   forAst: astNode) ].
	label = 'NotFollowedByAST' ifTrue: [
		^ cf notFollowedBy: (self
				   expectOneClauseIn: (self parseAstNodes: children)
				   forAst: astNode) ].
	label = 'LabelAST' ifTrue: [
		^ cf
			  astLabeled: astNode firstChild text
			  clause: (self parseAstNode: astNode secondChild firstChild) ].
	label = 'IdentAST' ifTrue: [
		^ cf ruleRefTo: astNode text "Rule name ref" ].
	label = 'QuotedStringAST' ifTrue: [ "Don't include surrounding quotes"
		^ cf str: (PikaStringUtils unescapeString: astNode text) ].
	label = 'SingleQuotedCharAST' ifTrue: [
		^ cf cInStr:
			  (String with: (PikaStringUtils unescapeChar: astNode text)) ].
	label = 'StartAST' ifTrue: [ ^ cf start ].
	label = 'AnythingAST' ifTrue: [ ^ cf anything ].
	label = 'NothingAST' ifTrue: [ ^ cf nothing ].
	label = 'CharRangeAST' ifTrue: [ ^ cf cRangeStr: astNode text ].

	"Keep recursing for parens (the only type of AST node that doesn't have a label)"
	^ self
		  expectOneClauseIn: (self parseAstNodes: children)
		  forAst: astNode
]

{ #category : 'private' }
PikaMetaGrammar class >> parseAstNodes: astNodes [
	"Recursively convert a list of AST nodes into a list of Clauses."

	| clauses |
	clauses := OrderedCollection new.
	astNodes do: [ :astNode | clauses add: (self parseAstNode: astNode) ].
	^ clauses
]

{ #category : 'private' }
PikaMetaGrammar class >> parseRule: ruleNode [
	"Parse a rule in the AST, returning a new Rule"

	"ruleNode is an AstNode"

	| ruleName hasPrecedence associativity precedence astNode clause |
	ruleName := ruleNode firstChild text.
	hasPrecedence := ruleNode children size > 2.
	associativity := ruleNode children size < 4
		                 ifTrue: [ nil ]
		                 ifFalse: [
			                 | assocLabel |
			                 assocLabel := ruleNode thirdChild label.
			                 assocLabel = 'LAssocAST'
				                 ifTrue: [ PikaRule leftAssociativity ]
				                 ifFalse: [
					                 assocLabel = 'LAssocAST'
						                 ifTrue: [ PikaRule rightAssociativity ]
						                 ifFalse: [ nil ] ] ].
	precedence := hasPrecedence
		              ifTrue: [ ruleNode secondChild text asNumber ]
		              ifFalse: [ -1 ].
	(hasPrecedence and: [ precedence < 0 ]) ifTrue: [
		self error:
			'Precedence needs to be zero or positive (rule ' , ruleName
			, ' has precedence level ' , precedence printString , ')' ].
	astNode := ruleNode lastChild.
	clause := self parseAstNode: astNode.
	^ PikaClauseFactory
		  ruleNamed: ruleName
		  precedence: precedence
		  associativity: associativity
		  clause: clause
]
