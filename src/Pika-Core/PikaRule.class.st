"
A grammar rule.

InstVars:

ruleName -- <String> The name of the rule

precedence -- <SmallInteger> The precedence of the rule, or -1 for no specified precedence.

associativity -- <Symbol> #LEFT, #RIGHT, or nil for no specified associativity.

labeledClause -- <PikaLabeledClause> The toplevel clause of the rule, and any associated AST node label.
"
Class {
	#name : 'PikaRule',
	#superclass : 'Object',
	#instVars : [
		'ruleName',
		'precedence',
		'associativity',
		'labeledClause'
	],
	#category : 'Pika-Core-grammar',
	#package : 'Pika-Core',
	#tag : 'grammar'
}

{ #category : 'constants' }
PikaRule class >> leftAssociativity [

	^ #LEFT
]

{ #category : 'instance creation' }
PikaRule class >> named: ruleName clause: clause [
	"Construct a rule with no specified precedence or associativity."

	"Use precedence of -1 for rules that only have one precedence
 (this causes the precedence number not to be shown in the output of printStringWithRuleNames)"

	^ self
		  named: ruleName
		  precedence: -1
		  associativity: nil
		  clause: clause
]

{ #category : 'instance creation' }
PikaRule class >> named: ruleName precedence: precedence associativity: associativity clause: clause [
	"Construct a rule with specified precedence and associativity."

	^ self new
		  ruleName: ruleName;
		  precedence: precedence;
		  associativity: associativity;
		  initializeForClause: clause;
		  yourself
]

{ #category : 'constants' }
PikaRule class >> rightAssociativity [

	^ #RIGHT
]

{ #category : 'accessing' }
PikaRule >> associativity [

	^ associativity
]

{ #category : 'accessing' }
PikaRule >> associativity: anObject [

	associativity := anObject
]

{ #category : 'accessing' }
PikaRule >> astNodeLabel [

	^ labeledClause astNodeLabel
]

{ #category : 'initialization' }
PikaRule >> initializeForClause: clause [

	| astNodeLabel clauseToUse |
	astNodeLabel := nil.
	clauseToUse := clause.
	clause isAstNodeLabel ifTrue: [ "Transfer ASTNodeLabel.astNodeLabel to astNodeLabel"
		astNodeLabel := clause label.
		"skip over ASTNodeLabel node when adding subClause to subClauses array"
		clauseToUse := clause subClause ].
	labeledClause := PikaLabeledClause
		                 forClause: clauseToUse
		                 labeled: astNodeLabel
]

{ #category : 'accessing' }
PikaRule >> labeledClause [

	^ labeledClause
]

{ #category : 'accessing' }
PikaRule >> labeledClause: anObject [

	labeledClause := anObject
]

{ #category : 'accessing' }
PikaRule >> precedence [

	^ precedence
]

{ #category : 'accessing' }
PikaRule >> precedence: anObject [

	precedence := anObject
]

{ #category : 'printing' }
PikaRule >> printOn: stream [

	stream
		<< ruleName;
		<< ' <- '.
	labeledClause printOn: stream.
	^ stream contents
]

{ #category : 'accessing' }
PikaRule >> ruleName [

	^ ruleName
]

{ #category : 'accessing' }
PikaRule >> ruleName: anObject [

	ruleName := anObject
]
