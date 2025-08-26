Class {
	#name : 'PikaGrammarUtils',
	#superclass : 'Object',
	#category : 'Pika-Core-utils',
	#package : 'Pika-Core',
	#tag : 'utils'
}

{ #category : 'public' }
PikaGrammarUtils class >> checkNoRefCyclesFromClause: clause name: nameString [

	self
		checkNoRefCyclesFromClause: clause
		name: nameString
		visited: Set new
]

{ #category : 'private' }
PikaGrammarUtils class >> checkNoRefCyclesFromClause: clause name: selfRefRuleName visited: visited [
	"Check there are no cycles in the clauses of rules, before RuleRef
	instances are resolved to direct references"

	(visited includes: clause) ifTrue: [
		self error:
			'Rules should not contain cycles when they are created: '
			, selfRefRuleName ].
	visited add: clause.
	clause labeledSubClauses do: [ :labeledSubClause |
		| subClause |
		subClause := labeledSubClause clause.
		self
			checkNoRefCyclesFromClause: subClause
			name: selfRefRuleName
			visited: visited ].
	visited remove: clause
]

{ #category : 'private' }
PikaGrammarUtils class >> countRuleSelfReferencesInClause: clause ruleBaseName: ruleNameWithoutPrecedence [
	"Count number of self-references among descendant clauses."

	| numSelfRefs |
	(clause isRuleRef and: [
		 clause refdRuleName = ruleNameWithoutPrecedence ]) ifTrue: [ ^ 1 ].
	numSelfRefs := 0.
	clause labeledSubClauses do: [ :labeledSubClause |
		| subClause |
		subClause := labeledSubClause clause.
		numSelfRefs := numSelfRefs + (self
	countRuleSelfReferencesInClause: subClause
	ruleBaseName: ruleNameWithoutPrecedence) ].
	^ numSelfRefs
]

{ #category : 'public' }
PikaGrammarUtils class >> findClauseTopoSortOrderTopLevelRule: topLevelRule allRules: allRules lowestPrecedenceClauses: lowestPrecedenceClauses [
	"Topologically sort all clauses into bottom-up order, from terminals up to the toplevel clause."

	| allClausesUnordered topLevelVisited topLevelClauses dfsRoots cycleDiscovered cycleFinished cycleHeadClauses terminalsVisited terminals allClauses reachableVisited index |
	allClausesUnordered := OrderedCollection new.
	topLevelVisited := Set new.

	"Add topLevel rule"
	topLevelRule ifNotNil: [
		| clause |
		clause := topLevelRule labeledClause clause.
		allClausesUnordered add: clause.
		topLevelVisited add: clause ].

	"Find any other toplevel clauses (clauses that are not a subclause of any other clause)"
	allRules do: [ :rule |
		self
			findReachableClausesInClause: rule labeledClause clause
			visited: topLevelVisited
			revTopoOrderOut: allClausesUnordered ].
	topLevelClauses := allClausesUnordered copy.
	allClausesUnordered do: [ :clause |
		clause labeledSubClauses do: [ :labeledSubClause |
			topLevelClauses remove: labeledSubClause clause ifAbsent: [  ] ] ].
	dfsRoots := OrderedCollection withAll: topLevelClauses.

	"Add to the end of the list of toplevel clauses all lowest-precedence clauses, since
    top-down precedence climbing should start at each lowest-precedence clause"
	dfsRoots addAll: lowestPrecedenceClauses.

	"Finally, in case there are cycles in the grammar that are not part of a precedence
	hierarchy, add to the end of the list of toplevel clauses the set of all 'head clauses'
	of cycles (the set of all clauses reached twice in some path through the grammar)"
	cycleDiscovered := Set new.
	cycleFinished := Set new.
	cycleHeadClauses := Set new.
	topLevelClauses do: [ :clause |
		self
			findCycleHeadClausesInClause: clause
			discovered: cycleDiscovered
			finished: cycleFinished
			cycleHeadClausesOut: cycleHeadClauses ].
	dfsRoots addAll: cycleHeadClauses.

	"Topologically sort all clauses into bottom-up order, starting with terminals (so that terminals are
	all grouped together at the beginning of the list)"
	terminalsVisited := Set new.
	terminals := OrderedCollection new.
	allRules do: [ :rule |
		self
			findTerminalsInClause: rule labeledClause clause
			visited: terminalsVisited
			terminalsOut: terminals ].
	allClauses := terminals copy.
	reachableVisited := Set withAll: terminals.
	dfsRoots do: [ :topLevelClause |
		self
			findReachableClausesInClause: topLevelClause
			visited: reachableVisited
			revTopoOrderOut: allClauses ].

	"Give each clause an index in the topological sort order, bottom-up"
	index := 1.
	allClauses do: [ :clause |
		clause clauseIdx: index.
		index := index + 1 ].
	^ allClauses
]

{ #category : 'private' }
PikaGrammarUtils class >> findCycleHeadClausesInClause: clause discovered: discovered finished: finished cycleHeadClausesOut: cycleHeadClausesOut [
	"Find the Clause nodes that complete a cycle in the grammar."

	clause isRuleRef ifTrue: [
		self error: 'There should not be any RuleRef nodes left in grammar' ].
	discovered add: clause.
	clause labeledSubClauses do: [ :labeledSubClause |
		| subClause |
		subClause := labeledSubClause clause.
		(discovered includes: subClause)
			ifTrue: [ "Reached a cycle" cycleHeadClausesOut add: subClause ]
			ifFalse: [
				(finished includes: subClause) ifFalse: [
					self
						findCycleHeadClausesInClause: subClause
						discovered: discovered
						finished: finished
						cycleHeadClausesOut: cycleHeadClausesOut ] ] ].
	discovered remove: clause.
	finished add: clause
]

{ #category : 'private' }
PikaGrammarUtils class >> findReachableClausesInClause: clause visited: visited revTopoOrderOut: revTopoOrderOut [
	"Find reachable clauses, and bottom-up (postorder), find clauses that always match in every position."

	(visited includes: clause) ifTrue: [ ^ self ].
	visited add: clause.
	clause labeledSubClauses do: [ :labeledSubClause |
		| subClause |
		subClause := labeledSubClause clause.
		self
			findReachableClausesInClause: subClause
			visited: visited
			revTopoOrderOut: revTopoOrderOut ].
	revTopoOrderOut add: clause
]

{ #category : 'private' }
PikaGrammarUtils class >> findTerminalsInClause: clause visited: visited terminalsOut: terminalsOut [
	"Find reachable clauses, and bottom-up (postorder), find clauses that always match in every position."

	(visited includes: clause) ifTrue: [ ^ self ].
	visited add: clause.
	clause isTerminal
		ifTrue: [ terminalsOut add: clause ]
		ifFalse: [
			clause labeledSubClauses do: [ :labeledSubClause |
				| subClause |
				subClause := labeledSubClause clause.
				self
					findTerminalsInClause: subClause
					visited: visited
					terminalsOut: terminalsOut ] ]
]

{ #category : 'public' }
PikaGrammarUtils class >> handlePrededenceOf: ruleNameWithoutPrecedence rules: rules lowestPrecedenceClauses: lowestPrecedenceClauses ruleNameDict: ruleNameDict [
	"Rewrite self-references in a precedence hierarchy into precedence-climbing form."

	"Rewrite rules

	For all but the highest precedence level:

	E[0] <- E (Op E)+  =>  E[0] <- (E[1] (Op E[1])+) / E[1] 
	E[0,L] <- E Op E   =>  E[0] <- (E[0] Op E[1]) / E[1] 
	E[0,R] <- E Op E   =>  E[0] <- (E[1] Op E[0]) / E[1]
	E[3] <- '-' E      =>  E[3] <- '-' (E[3] / E[4]) / E[4]

	For highest precedence level, next highest precedence wraps back to lowest precedence level:

	E[5] <- '(' E ')'  =>  E[5] <- '(' E[0] ')'"

	| precedences sortedRules precedenceOrder numPrecedenceLevels lowestPrecRule |
	precedences := Set new.
	sortedRules := SkipList new.
	rules do: [ :rule |
		| precedence |
		precedence := rule precedence.
		(precedences includes: precedence) ifTrue: [
			^ self error:
				  'Multiple rules with name ' , ruleNameWithoutPrecedence
				  , (precedence = -1
						   ifTrue: [ '' ]
						   ifFalse: [ ' and precedence ' , precedence printString ]) ].
		precedences add: precedence.
		sortedRules at: precedence put: rule ].

	"Get rules in ascending order of precedence"
	precedenceOrder := sortedRules asArray.

	"Rename rules to include precedence level"
	precedenceOrder do: [ :rule | "Since there is more than one precedence level, update rule name to include precedence"
		rule ruleName:
			rule ruleName , '[' , rule precedence printString , ']' ].

	"Transform grammar rule to handle precence"
	numPrecedenceLevels := rules size.
	1 to: numPrecedenceLevels do: [ :precedenceIdx |
		| rule numSelfRefs currPrecRuleName nextHighestPrecRuleName isHighestPrec |
		rule := precedenceOrder at: precedenceIdx.

		"Count the number of self-reference operands"
		numSelfRefs := self
			               countRuleSelfReferencesInClause:
			               rule labeledClause clause
			               ruleBaseName: ruleNameWithoutPrecedence.
		currPrecRuleName := rule ruleName.
		nextHighestPrecRuleName := (precedenceOrder at:
			                            precedenceIdx \\ numPrecedenceLevels
			                            + 1) ruleName.

		"If a rule has 1+ self-references, need to rewrite rule to handle precedence and associativity"
		isHighestPrec := precedenceIdx = numPrecedenceLevels.
		numSelfRefs >= 1 ifTrue: [ "Rewrite self-references to higher precedence or left- and right-recursive forms.
			(the toplevel clause of the rule, rule.labeledClause.clause, can't be a self-reference,
			since we already checked for that, and IllegalArgumentException would have been thrown.)"
			self
				rewriteSelfReferencesInClause: rule labeledClause clause
				associativity: rule associativity
				numSelfRefsSoFar: 0
				numSelfRefs: numSelfRefs
				selfRefRuleName: ruleNameWithoutPrecedence
				isHighestPrec: isHighestPrec
				currPrecRuleName: currPrecRuleName
				nextHighestPrecRuleName: nextHighestPrecRuleName ].

		"Defer to next highest level of precedence if the rule doesn't match, except at the highest level of
			precedence, which is assumed to be a precedence-breaking pattern (like parentheses), so should not
			defer back to the lowest precedence level unless the pattern itself matches"
		isHighestPrec ifFalse: [
			| first |
			"Move rule's toplevel clause (and any AST node label it has) into the first subclause of
			a First clause that fails over to the next highest precedence level"
			first := PikaFirstClause withSubClauses: {
					         rule labeledClause clause.
					         (PikaRuleRef withRuleName: nextHighestPrecRuleName) }.
			"Move any AST node label down into first subclause of new First clause, so that label doesn't
	apply to the final failover rule reference"
			(first labeledSubClauses at: 1) astNodeLabel:
				rule labeledClause astNodeLabel.
			rule labeledClause astNodeLabel: nil.
			"Replace rule clause with new First clause"
			rule labeledClause clause: first ] ].

	"Map the bare rule name (without precedence suffix) to the lowest precedence level rule name"
	lowestPrecRule := precedenceOrder first.
	lowestPrecedenceClauses add: lowestPrecRule labeledClause clause.
	ruleNameDict
		at: ruleNameWithoutPrecedence
		put: lowestPrecRule ruleName
]

{ #category : 'public' }
PikaGrammarUtils class >> internClause: clause dict: printStringToClause [
	"Recursively send #printString on the clause tree for this Rule, so that printString values are cached
	before RuleRef objects are replaced with direct references, and so that shared subclauses are only
	matched once."

	| printStr |
	clause labeledSubClauses do: [ :labeledSubClause | "Send #printString to (and intern) subclauses, bottom-up"
		labeledSubClause clause:
			(self
				 internClause: labeledSubClause clause
				 dict: printStringToClause) ].

	"Send #printString after recursing to child nodes"
	printStr := clause printString.

	"Intern the clause based on the toString value.
	Return the previously-interned clause, if present, otherwise the clause, if it was just interned"
	^ printStringToClause at: printStr ifAbsentPut: [ clause ]
]

{ #category : 'public' }
PikaGrammarUtils class >> resolveRuleRefsLabeledClause: labeledClause ruleNameToRule: ruleNameToRule ruleNameToLowestPrecedenceLevelRuleName: ruleNameToLowestPrecedenceLevelRuleName visited: visited [
	"Resolve RuleRef clauses to a reference to the named rule."

	labeledClause clause isRuleRef
		ifTrue: [ "Follow a chain of from name in RuleRef objects until a non-RuleRef is reached"
			| currLabeledClause visitedClauses |
			currLabeledClause := labeledClause.
			visitedClauses := Set new.
			[ currLabeledClause clause isRuleRef ] whileTrue: [
				| clause refdRuleName lowestPrecRuleName refdRule |
				clause := currLabeledClause clause.
				(visitedClauses includes: clause) ifTrue: [
					self error:
						'Reached toplevel RuleRef cycle: ' , clause printString ].

				"Follow a chain of from name in RuleRef objects until a non-RuleRef is reached"
				refdRuleName := clause refdRuleName.

				"Check if the rule is the reference to the lowest precedence rule of a precedence hierarchy"
				lowestPrecRuleName := ruleNameToLowestPrecedenceLevelRuleName
					                      at: refdRuleName
					                      ifAbsent: [ refdRuleName ].

				"Look up Rule based on rule name"
				refdRule := ruleNameToRule
					            at: lowestPrecRuleName
					            ifAbsent: [
					            self error: 'Unknown rule name: ' , refdRuleName ].
				currLabeledClause := refdRule labeledClause ].
			"Set current clause to a direct reference to the referenced rule"
			labeledClause clause: currLabeledClause clause.

			"Copy across AST node label, if any"
			labeledClause astNodeLabel ifNil: [
				labeledClause astNodeLabel: currLabeledClause astNodeLabel ] ]
		ifFalse: [ "Stop recursing at RuleRef"
			| labeledSubClauses |
			(visited includes: labeledClause clause) ifFalse: [
				visited add: labeledClause clause.
				labeledSubClauses := labeledClause clause labeledSubClauses.
				labeledSubClauses do: [ :labeledSubClause | "Recurse through subclause tree if subclause was not a RuleRef "
					self
						resolveRuleRefsLabeledClause: labeledSubClause
						ruleNameToRule: ruleNameToRule
						ruleNameToLowestPrecedenceLevelRuleName:
						ruleNameToLowestPrecedenceLevelRuleName
						visited: visited ] ] ]
]

{ #category : 'private' }
PikaGrammarUtils class >> rewriteSelfReferencesInClause: clause associativity: associativity numSelfRefsSoFar: numSelfRefsSoFarAtEntry numSelfRefs: numSelfRefs selfRefRuleName: selfRefRuleName isHighestPrec: isHighestPrec currPrecRuleName: currPrecRuleName nextHighestPrecRuleName: nextHighestPrecRuleName [
	"Rewrite self-references into precedence-climbing form."

	| numSelfRefsSoFar |
	numSelfRefsSoFar := numSelfRefsSoFarAtEntry.
	numSelfRefsSoFar < numSelfRefs ifTrue: [ "Terminate recursion when all self-refs have been replaced"
		1 to: clause labeledSubClauses size do: [ :i |
			| labeledSubClause subClause |
			labeledSubClause := clause labeledSubClauses at: i.
			subClause := labeledSubClause clause.
			subClause isRuleRef
				ifTrue: [
					subClause refdRuleName = selfRefRuleName ifTrue: [
						numSelfRefs >= 2
							ifTrue: [ "Change name of self-references to implement precedence climbing:
						For leftmost operand of left-recursive rule:
						E[i] <- E X E  =>  E[i] = E[i] X E[i+1]
						For rightmost operand of right-recursive rule:
						E[i] <- E X E  =>  E[i] = E[i+1] X E[i]
						For non-associative rule:
						E[i] = E E  =>  E[i] = E[i+1] E[i+1]"
								| newRuleName |
								newRuleName := ((associativity = PikaRule leftAssociativity
									                 and: [ numSelfRefsSoFar = 0 ]) or: [
									                associativity = PikaRule rightAssociativity
										                and: [ numSelfRefsSoFar = numSelfRefs ] ])
									               ifTrue: [ currPrecRuleName ]
									               ifFalse: [ nextHighestPrecRuleName ].
								(clause labeledSubClauses at: i) clause:
									(PikaRuleRef withRuleName: newRuleName) ]
							ifFalse: [ "numSelfRefs == 1"
								isHighestPrec
									ifFalse: [ "Move subclause (and its AST node label, if any) 
								inside a First clause that climbs precedence to the next level:
								E[i] <- X E Y  =>  E[i] <- X (E[i] / E[(i+1)%N]) Y"
										subClause refdRuleName: currPrecRuleName.
										(clause labeledSubClauses at: i) clause:
											(PikaFirstClause withSubClauses: {
													 subClause.
													 (PikaRuleRef withRuleName: nextHighestPrecRuleName) }) ]
									ifTrue: [ "Except for highest precedence, just defer back to lowest-prec level:
											E[N-1] <- '(' E ')'  =>  E[N-1] <- '(' E[0] ')' "
										subClause refdRuleName: nextHighestPrecRuleName ] ].
						numSelfRefsSoFar := numSelfRefsSoFar + 1 ] ]
				ifFalse: [ "Else don't rewrite the RuleRef, it is not a self-ref"
					numSelfRefsSoFar := self
						                    rewriteSelfReferencesInClause: subClause
						                    associativity: associativity
						                    numSelfRefsSoFar: numSelfRefsSoFar
						                    numSelfRefs: numSelfRefs
						                    selfRefRuleName: selfRefRuleName
						                    isHighestPrec: isHighestPrec
						                    currPrecRuleName: currPrecRuleName
						                    nextHighestPrecRuleName:
						                    nextHighestPrecRuleName ].
			subClause printStringCached: nil ] ].
	^ numSelfRefsSoFar
]
