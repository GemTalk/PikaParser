"
A grammar. The #parse: method runs the parser on the provided input string.
"
Class {
	#name : 'PikaGrammar',
	#superclass : 'Object',
	#instVars : [
		'allRules',
		'ruleNameWithPrecedenceToRule',
		'allClauses'
	],
	#classInstVars : [
		'debug'
	],
	#category : 'Pika-Core-grammar',
	#package : 'Pika-Core',
	#tag : 'grammar'
}

{ #category : 'accessing' }
PikaGrammar class >> debug [

	^ debug
]

{ #category : 'accessing' }
PikaGrammar class >> debug: aBoolean [
	"self debug: true.
	self debug: false."

	^ debug := aBoolean
]

{ #category : 'instance creation' }
PikaGrammar class >> forRules: rules [
	"Construct a grammar from a set of rules. The first rule should be the toplevel rule."

	rules isEmpty ifTrue: [
		self error: 'Grammar must consist of at least one rule' ].
	^ self new initializeForRules: rules
]

{ #category : 'class initialization' }
PikaGrammar class >> initialize [

	debug := false
]

{ #category : 'accessing' }
PikaGrammar >> allClauses [

	^ allClauses
]

{ #category : 'initialization' }
PikaGrammar >> findSeedParentClauses [
	"Find seed parent clauses (in the case of Seq, this depends upon alwaysMatches being set in the prev step)"

	allClauses do: [ :clause | clause addAsSeedParentClause ]
]

{ #category : 'initialization' }
PikaGrammar >> handlePrecedenceOfRuleDict: ruleNameToRules lowestPrecedenceClauses: lowestPrecedenceClauses lowestPrecedenceRuleNameDict: ruleNameToLowestPrecedenceLevelRuleName [
	"If there is more than one precedence level for a rule, the handlePrecedence message modifies
	rule names to include a precedence suffix, and also adds an all-precedence selector clause with the
	original rule name. On return, all rule names should be unique."

	ruleNameToRules keysAndValuesDo: [ :ruleName :rulesWithName |
		rulesWithName size > 1 ifTrue: [
			PikaGrammarUtils
				handlePrededenceOf: ruleName
				rules: rulesWithName
				lowestPrecedenceClauses: lowestPrecedenceClauses
				ruleNameDict: ruleNameToLowestPrecedenceLevelRuleName ] ].
	allRules do: [ :rule | "The handlePrecedence message above added the precedence to the rule name as a suffix"
		ruleNameWithPrecedenceToRule
			at: rule ruleName
			ifPresent: [ self error: 'Duplicate rule name ' , rule name ]
			ifAbsentPut: [ rule ] ]
]

{ #category : 'initialization' }
PikaGrammar >> initialize [

	super initialize.
	allRules := OrderedCollection new.
	ruleNameWithPrecedenceToRule := Dictionary new
]

{ #category : 'initialization' }
PikaGrammar >> initializeForRules: rules [

	| topLevelRule ruleNameToRules ruleNameToLowestPrecedenceLevelRuleName lowestPrecedenceClauses clausesVisitedResolveRuleRefs |
	"Assume the first rule is the toplevel rule"
	topLevelRule := rules first.
	ruleNameToRules := self ruleDictionaryFromRules: rules.
	allRules := OrderedCollection withAll: rules.
	ruleNameToLowestPrecedenceLevelRuleName := Dictionary new.
	lowestPrecedenceClauses := OrderedCollection new.
	self
		handlePrecedenceOfRuleDict: ruleNameToRules
		lowestPrecedenceClauses: lowestPrecedenceClauses
		lowestPrecedenceRuleNameDict:
		ruleNameToLowestPrecedenceLevelRuleName.
	allRules do: [ :rule | rule labeledClause clause registerRule: rule ].
	self internClauses.
	"Resolve each RuleRef into a direct reference to the referenced clause"
	clausesVisitedResolveRuleRefs := Set new.
	allRules do: [ :rule |
		PikaGrammarUtils
			resolveRuleRefsLabeledClause: rule labeledClause
			ruleNameToRule: ruleNameWithPrecedenceToRule
			ruleNameToLowestPrecedenceLevelRuleName:
			ruleNameToLowestPrecedenceLevelRuleName
			visited: clausesVisitedResolveRuleRefs ].
	allClauses := PikaGrammarUtils
		              findClauseTopoSortOrderTopLevelRule: topLevelRule
		              allRules: allRules
		              lowestPrecedenceClauses: lowestPrecedenceClauses.
	self
		propagateZeroLengthMatches;
		findSeedParentClauses
]

{ #category : 'initialization' }
PikaGrammar >> internClauses [
	"Intern clauses based on their printString, coalescing shared sub-clauses into a DAG, so that
	effort is not wasted parsing different instances of the same clause multiple times, and so that
	when a subclause matches, all parent clauses will be added to the active set in the next iteration.
	Also causes the printStrings to be cached, so that after RuleRefs are replaced with direct
	Clause references, printString doesn't get stuck in an infinite loop."

	| toStringToClause |
	toStringToClause := Dictionary new.
	allRules do: [ :rule |
		rule labeledClause clause: (PikaGrammarUtils
				 internClause: rule labeledClause clause
				 dict: toStringToClause) ]
]

{ #category : 'accessing' }
PikaGrammar >> navigableMatchesForRule: ruleName memoTable: memoTable [
	"Answer all Match entries for the given clause, indexed by start position.
	Answer a SortedCollection of Associations, startPos -> match."

	^ memoTable navigableMatchesForClause:
		  (self ruleNamed: ruleName) labeledClause clause
]

{ #category : 'accessing' }
PikaGrammar >> nonOverlappingMatchesForRule: ruleName memoTable: memoTable [
	"Answer the Match entries for all nonoverlapping matches of the named rule, obtained by greedily matching
	from the beginning of the string, then looking for the next match after the end of the current match."

	^ memoTable nonOverlappingMatchesForClause:
		  (self ruleNamed: ruleName) labeledClause clause
]

{ #category : 'parsing' }
PikaGrammar >> parse: inputString [
	"Main parsing method.
	Answer the resulting MemoTable"

	| priorityQueue memoTable terminals |
	priorityQueue := Heap sortBlock: [ :clause1 :clause2 |
		                 clause1 clauseIdx < clause2 clauseIdx ].
	memoTable := PikaMemoTable forGrammar: self inputString: inputString.
	terminals := allClauses select: [ :clause |
		             clause isTerminal and: [ clause isNothingClause not ] ].
	inputString size to: 1 by: -1 do: [ :startPos |
		self class debug ifTrue: [
			| stdout |
			stdout := ZnCharacterWriteStream
				          on: (ZnBufferedWriteStream on: Stdio stdout)
				          encoding: 'utf8'.
			stdout << '=============== POSITION: '.
			startPos printOn: stdout.
			stdout << ' CHARACTER:['.
			(inputString at: startPos) printOn: stdout.
			stdout
				<< '] ===============';
				lf;
				flush ].
		priorityQueue addAll: terminals.
		[ priorityQueue isEmpty ] whileFalse: [ "Remove a clause from the priority queue (ordered from terminals to toplevel clauses)"
			| clause memoKey match |
			clause := priorityQueue removeFirst.
			memoKey := PikaMemoKey clause: clause startPos: startPos.
			match := clause
				         matchInput: inputString
				         key: memoKey
				         inTable: memoTable.
			memoTable
				addMatch: match
				withKey: memoKey
				priorityQueue: priorityQueue ] ].

	^ memoTable
]

{ #category : 'printing' }
PikaGrammar >> printRules [

	| s |
	s := WriteStream on: String new.
	self printRulesOn: s.
	^ s contents
]

{ #category : 'printing' }
PikaGrammar >> printRulesOn: aStream [

	allRules do: [ :rule |
		rule printOn: aStream.
		aStream lf ]
]

{ #category : 'initialization' }
PikaGrammar >> propagateZeroLengthMatches [
	"Find clauses that always match zero or more characters, e.g. FirstMatch(X | Nothing).
	Importantly, allClauses is in reverse topological order, i.e. traversal is bottom-up."

	| changed |
	changed := true.
	[ changed ] whileTrue: [
		changed := false.
		allClauses do: [ :clause |
			clause determineWhetherCanMatchZeroChars ifTrue: [ changed := true ] ] ]
]

{ #category : 'initialization' }
PikaGrammar >> ruleDictionaryFromRules: rules [
	"Group rules by name"

	| ruleNameToRules |
	ruleNameToRules := Dictionary new.
	rules do: [ :rule |
		| clause rulesWithName |
		rule ruleName ifNil: [ self error: 'All rules must be named' ].
		clause := rule labeledClause clause.
		(clause isRuleRef and: [ clause refdRuleName = rule ruleName ])
			ifTrue: [ "Make sure rule doesn't refer only to itself"
				self error:
					'Rule cannot refer to only itself: ' , rule name , '['
					, rule precedence printString , ']' ].

		rulesWithName := ruleNameToRules
			                 at: rule ruleName
			                 ifAbsentPut: OrderedCollection new.
		rulesWithName add: rule.
		"Make sure there are no cycles in the grammar before RuleRef instances have been replaced
       with direct references (checking once up front simplifies other recursive routines, so that
       they don't have to check for infinite recursion)"
		PikaGrammarUtils
			checkNoRefCyclesFromClause: clause
			name: rule ruleName ].
	^ ruleNameToRules
]

{ #category : 'accessing' }
PikaGrammar >> ruleNamed: ruleNameWithPrecedence [

	| rule |
	rule := self
		        ruleNamed: ruleNameWithPrecedence
		        ifAbsent: [
		        self error: 'Unknown rule name: ' , ruleNameWithPrecedence ].
	^ rule
]

{ #category : 'accessing' }
PikaGrammar >> ruleNamed: ruleNameWithPrecedence ifAbsent: absentBlock [

	^ self
		  ruleNamed: ruleNameWithPrecedence
		  ifPresent: [ :rule | rule ]
		  ifAbsent: absentBlock
]

{ #category : 'accessing' }
PikaGrammar >> ruleNamed: ruleNameWithPrecedence ifPresent: presentBlock ifAbsent: absentBlock [

	^ ruleNameWithPrecedenceToRule
		  at: ruleNameWithPrecedence
		  ifPresent: [ :rule | presentBlock value: rule ]
		  ifAbsent: absentBlock
]

{ #category : 'accessing' }
PikaGrammar >> topLevelRule [
	"Assume that the first rule is my top-level rule, and that there is only one top-level rule"

	| firstRule lastClause |
	firstRule := allRules first.
	lastClause := allClauses last.
	firstRule labeledClause clause == lastClause ifFalse: [
		self error: 'First rule and highest-order clause do not match' ].
	^ firstRule
]
