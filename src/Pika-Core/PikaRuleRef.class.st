"
Placeholder clause for referring to another rule by name. These clauses are replaced with direct references to
the clauses they reference by name before parsing begins, in order to optimize parsing.
"
Class {
	#name : 'PikaRuleRef',
	#superclass : 'PikaClause',
	#instVars : [
		'refdRuleName'
	],
	#category : 'Pika-Core-clause',
	#package : 'Pika-Core',
	#tag : 'clause'
}

{ #category : 'instance creation' }
PikaRuleRef class >> withRuleName: nameString [

	| inst |
	inst := self withSubClauses: {  }.
	inst refdRuleName: nameString.
	^ inst
]

{ #category : 'matching' }
PikaRuleRef >> determineWhetherCanMatchZeroChars [

	^ false
]

{ #category : 'testing' }
PikaRuleRef >> isRuleRef [

	^ true
]

{ #category : 'as yet unclassified' }
PikaRuleRef >> matchInput: inputString key: memoKey inTable: memoTable [

	self error: self class name , ' node should not be in final grammar'
]

{ #category : 'printing' }
PikaRuleRef >> printOn: aStream [

	printStringCached ifNil: [ printStringCached := refdRuleName ].
	aStream << printStringCached
]

{ #category : 'accessing' }
PikaRuleRef >> refdRuleName [

	^ refdRuleName
]

{ #category : 'accessing' }
PikaRuleRef >> refdRuleName: anObject [

	refdRuleName := anObject
]
