"
Abstract superclass of all PEG operators and terminals.

Instance variables:

labeledSubClauses
	Subclauses, paired with their AST node label (if there is one).

rules
	Rules this clause is a toplevel clause of (used by #toStringWithRuleNames).
	
seedParentClauses
	The parent clauses of this clause that should be matched in the same start position.
	
canMatchZeroChars
	If true, the clause can match while consuming zero characters.
	
clauseIdx
	Index in the topological sort order of clauses, bottom-up.
	
printStringCached
	cached result of #printString
	
printStringWithRuleNameCached
	cached result of #printStringWithRuleNames
"
Class {
	#name : 'PikaClause',
	#superclass : 'Object',
	#instVars : [
		'labeledSubClauses',
		'rules',
		'seedParentClauses',
		'canMatchZeroChars',
		'clauseIdx',
		'printStringCached',
		'printStringWithRuleNameCached'
	],
	#category : 'Pika-Core-clause',
	#package : 'Pika-Core',
	#tag : 'clause'
}

{ #category : 'instance creation' }
PikaClause class >> withSubClauses: clauses [

	(clauses notEmpty and: [ clauses first isNothingClause ]) ifTrue: [ "Nothing can't be the first
		 subclause, since we don't trigger upwards expansion of the DP wavefront
		by seeding the memo table by matching Nothing at every input position, to keep the memo table small"
		self error:
			'A Nothing clause cannot be the first subclause of any clause' ].
	^ self new initializeWithSubClauses: clauses
]

{ #category : 'adding' }
PikaClause >> addAsSeedParentClause [
	"Find which subclauses need to add this clause as a 'seed parent clause.' Overridden in Seq."

	| added |
	added := Set new.
	"Default implementation: all subclauses will seed this parent clause"
	labeledSubClauses do: [ :each | "Don't duplicate seed parent clauses in the subclause"
		(added includes: each) ifFalse: [ each addSeedParentClause: self ].
		added add: each ]
]

{ #category : 'adding' }
PikaClause >> addSeedParentClause: aClause [

	seedParentClauses add: aClause
]

{ #category : 'accessing' }
PikaClause >> canMatchZeroChars [

	^ canMatchZeroChars
]

{ #category : 'accessing' }
PikaClause >> canMatchZeroChars: anObject [

	canMatchZeroChars := anObject
]

{ #category : 'accessing' }
PikaClause >> clauseIdx [

	^ clauseIdx
]

{ #category : 'accessing' }
PikaClause >> clauseIdx: anObject [

	clauseIdx := anObject
]

{ #category : 'matching' }
PikaClause >> determineWhetherCanMatchZeroChars [
	"Sets canMatchZeroChars to true if this clause can match zero characters, i.e. always matches at any
     input position. Called bottom-up. Implemented in subclasses. Returns true if canMatchZeroChars is
     flipped from false to true. (Return false for terminals like Nothing that always return true.)"

	self subclassResponsibility
]

{ #category : 'testing' }
PikaClause >> doesOneOrMoreOfMeHaveAnEffect [
	"Answer true if I am a reasonable subclasue of a OneOrMore clause"

	^ true
]

{ #category : 'testing' }
PikaClause >> hasMatchedRules [

	^ rules isNotEmpty
]

{ #category : 'initialization' }
PikaClause >> initialize [

	super initialize.
	canMatchZeroChars := false.
	rules := OrderedCollection new.
	seedParentClauses := OrderedCollection new
]

{ #category : 'initialization' }
PikaClause >> initializeWithSubClauses: clauses [

	labeledSubClauses := OrderedCollection new: clauses size.
	clauses do: [ :subClause |
		| astNodeLabel |
		labeledSubClauses add: (subClause isAstNodeLabel
				 ifTrue: [ "Transfer ASTNodeLabel.astNodeLabel to LabeledClause.astNodeLabel field"
					 astNodeLabel := subClause label.
					 "skip over ASTNodeLabel node when adding subClause to subClauses array"
					 PikaLabeledClause
						 forClause: subClause labeledSubClauses first clause
						 labeled: astNodeLabel ]
				 ifFalse: [ PikaLabeledClause forClause: subClause labeled: nil ]) ]
]

{ #category : 'testing' }
PikaClause >> isAstNodeLabel [

	^ false
]

{ #category : 'testing' }
PikaClause >> isFirst [

	^ false
]

{ #category : 'testing' }
PikaClause >> isNotFollowedByClause [

	^ false
]

{ #category : 'testing' }
PikaClause >> isNothingClause [

	^ false
]

{ #category : 'testing' }
PikaClause >> isRuleRef [

	^ false
]

{ #category : 'testing' }
PikaClause >> isSeq [
	"Answer true if I'm a sequence clause"

	^ false
]

{ #category : 'testing' }
PikaClause >> isTerminal [

	^ false
]

{ #category : 'accessing' }
PikaClause >> label [

	^ nil
]

{ #category : 'accessing' }
PikaClause >> labeledSubClauses [

	^ labeledSubClauses
]

{ #category : 'accessing' }
PikaClause >> labeledSubClauses: anObject [

	labeledSubClauses := anObject
]

{ #category : 'testing' }
PikaClause >> makesSenseForFollowedBy [
	"Answer true if I make sense as the subClause of a FollowedBy clause"

	^ true
]

{ #category : 'testing' }
PikaClause >> makesSenseForNotFollowedBy [
	"Answer true if I make sense as the subClause of a NotFollowedBy clause"

	^ true
]

{ #category : 'matching' }
PikaClause >> matchInput: inputString key: aMemoKey inTable: aMemoTable [
	" * Match a clause by looking up its subclauses in the memotable (in the case of nonterminals), or by looking at
     * the input string (in the case of terminals). Implemented in subclasses."

	self subclassResponsibility
]

{ #category : 'printing' }
PikaClause >> printOn: aStream [

	self subclassResponsibility
]

{ #category : 'accessing' }
PikaClause >> printStringCached [

	^ printStringCached
]

{ #category : 'accessing' }
PikaClause >> printStringCached: anObject [

	printStringCached := anObject
]

{ #category : 'printing' }
PikaClause >> printWithRuleNamesOn: aStream [
	"Get the clause as a string, with rule names prepended if the clause is the toplevel clause of a rule."

	printStringWithRuleNameCached ifNil: [
		| localStream |
		localStream := WriteStream on: String new.
		rules isEmpty
			ifTrue: [ self printOn: localStream ]
			ifFalse: [
				| addedAstNodeLabels addParens |
				addedAstNodeLabels := false.
				localStream
					<< self ruleNames;
					<< ' <- '.
				rules do: [ :rule |
					| label |
					label := rule astNodeLabel.
					label ifNotNil: [
						localStream
							<< label;
							<< ':'.
						addedAstNodeLabels := true ] ].
				addParens := addedAstNodeLabels and: [
					             PikaMetaGrammar
						             needToAddParensAroundAstNodeLabelOfClause: self ].
				addParens ifTrue: [ localStream << '(' ].
				self printOn: localStream.
				addParens ifTrue: [ localStream << ')' ] ].
		printStringWithRuleNameCached := localStream contents ].
	aStream nextPutAll: printStringWithRuleNameCached
]

{ #category : 'accessing' }
PikaClause >> registerRule: rule [
	"Register this clause with a rule (used by #toStringWithRuleNames)."

	rules add: rule
]

{ #category : 'initialization' }
PikaClause >> resetPrintString [

	printStringCached := nil
]

{ #category : 'printing' }
PikaClause >> ruleNames [
	" Get the names of rules that this clause is the root clause of."

	^ ', ' join: (rules collect: [ :each | each ruleName ]) sorted
]

{ #category : 'accessing' }
PikaClause >> rules [

	^ rules
]

{ #category : 'accessing' }
PikaClause >> seedParentClauses [

	^ seedParentClauses
]

{ #category : 'accessing' }
PikaClause >> seedParentClauses: anObject [

	seedParentClauses := anObject
]

{ #category : 'accessing' }
PikaClause >> subClauseMatchesForMatch: aMatch [
	"Answer labeled subclause matches"

	^ aMatch subClauseMatchesForOtherClauses
]

{ #category : 'accessing' }
PikaClause >> unRegisterRule: rule [
	"Unregister this clause from a rule."

	self flag: 'Unused?'.
	rules remove: rule
]
