"
A terminal clause that only matches at input position 0.
"
Class {
	#name : 'PikaStartClause',
	#superclass : 'PikaTerminalClause',
	#category : 'Pika-Core-clause-terminal',
	#package : 'Pika-Core',
	#tag : 'clause-terminal'
}

{ #category : 'matching' }
PikaStartClause >> determineWhetherCanMatchZeroChars [
	"Well, it always matches zero characters. But the logic in bestMatchFor: will make a match for it anyway, deny it."

	canMatchZeroChars := false.
	^ false
]

{ #category : 'as yet unclassified' }
PikaStartClause >> doesOneOrMoreOfMeHaveAnEffect [

	^ false
]

{ #category : 'testing' }
PikaStartClause >> makesSenseForFollowedBy [
	"Answer true if I make sense as the subClause of a FollowedBy clause"

	^ false
]

{ #category : 'testing' }
PikaStartClause >> makesSenseForNotFollowedBy [
	"Answer true if I make sense as the subClause of a NotFollowedBy clause"

	^ false
]

{ #category : 'matching' }
PikaStartClause >> matchInput: inputString key: memoKey inTable: memoTable [

	memoKey startPos = 1 ifTrue: [ ^ PikaMatch memoKey: memoKey ].
	^ nil
]

{ #category : 'printing' }
PikaStartClause >> printOn: aStream [

	printStringCached ifNil: [ printStringCached := '^' ].
	aStream << printStringCached
]
