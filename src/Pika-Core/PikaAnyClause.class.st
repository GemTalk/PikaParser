"
A terminal clause that matches any one character, thus matches at all input positions except one past the end.
"
Class {
	#name : 'PikaAnyClause',
	#superclass : 'PikaTerminalClause',
	#category : 'Pika-Core-clause-terminal',
	#package : 'Pika-Core',
	#tag : 'clause-terminal'
}

{ #category : 'matching' }
PikaAnyClause >> determineWhetherCanMatchZeroChars [

	canMatchZeroChars := false.
	^ false
]

{ #category : 'testing' }
PikaAnyClause >> makesSenseForFollowedBy [
	"Answer true if I make sense as the subClause of a FollowedBy clause"

	^ true
]

{ #category : 'testing' }
PikaAnyClause >> makesSenseForNotFollowedBy [
	"Answer true if I make sense as the subClause of a NotFollowedBy clause"

	^ true
]

{ #category : 'matching' }
PikaAnyClause >> matchInput: inputString key: memoKey inTable: memoTable [

	memoKey startPos <= inputString size ifTrue: [
		^ PikaMatch memoKey: memoKey len: 1 input: inputString ].
	^ nil
]

{ #category : 'printing' }
PikaAnyClause >> printOn: aStream [

	printStringCached ifNil: [ printStringCached := '.' ].
	aStream << printStringCached
]
