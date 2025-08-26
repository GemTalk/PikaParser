"
The Nothing (epsilon / empty string) terminal clause.
"
Class {
	#name : 'PikaNothingClause',
	#superclass : 'PikaTerminalClause',
	#category : 'Pika-Core-clause-terminal',
	#package : 'Pika-Core',
	#tag : 'clause-terminal'
}

{ #category : 'matching' }
PikaNothingClause >> determineWhetherCanMatchZeroChars [

	canMatchZeroChars := true.
	^ false
]

{ #category : 'testing' }
PikaNothingClause >> doesOneOrMoreOfMeHaveAnEffect [

	^ false
]

{ #category : 'testing' }
PikaNothingClause >> isNothingClause [

	^ true
]

{ #category : 'matching' }
PikaNothingClause >> matchInput: inputString key: aMemoKey inTable: aMemoTable [

	^ PikaMatch memoKey: aMemoKey
]

{ #category : 'matching' }
PikaNothingClause >> matchTable: table key: memoKey input: input [

	^ PikaMatch memoKey: memoKey
]

{ #category : 'printing' }
PikaNothingClause >> printOn: aStream [

	printStringCached ifNil: [ printStringCached := '()' ].
	aStream << printStringCached
]
