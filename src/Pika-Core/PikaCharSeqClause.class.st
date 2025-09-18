"
Terminal clause that matches a token in the input string.
"
Class {
	#name : 'PikaCharSeqClause',
	#superclass : 'PikaTerminalClause',
	#instVars : [
		'str',
		'ignoreCase'
	],
	#category : 'Pika-Core-clause-terminal',
	#package : 'Pika-Core',
	#tag : 'clause-terminal'
}

{ #category : 'instance creation' }
PikaCharSeqClause class >> string: str ignoreCase: ignoreCase [

	^ super new
		  str: str;
		  ignoreCase: ignoreCase;
		  yourself
]

{ #category : 'matching' }
PikaCharSeqClause >> determineWhetherCanMatchZeroChars [

	str isEmpty ifTrue: [ canMatchZeroChars := true ].
	^ false
]

{ #category : 'accessing' }
PikaCharSeqClause >> ignoreCase [

	^ ignoreCase
]

{ #category : 'accessing' }
PikaCharSeqClause >> ignoreCase: anObject [

	ignoreCase := anObject
]

{ #category : 'matching' }
PikaCharSeqClause >> matchInput: inputString key: memoKey inTable: memoTable [

	memoKey startPos <= (inputString size - str size + 1) and: [
		| op1 op2 |
		op1 := str.
		op2 := inputString
			       copyFrom: memoKey startPos
			       to: memoKey startPos + str size - 1.
		ignoreCase ifTrue: [
			op1 := op1 asUppercase.
			op2 := op2 asUppercase ].
		op1 = op2 ifTrue: [
			^ PikaMatch memoKey: memoKey len: str size input: inputString ] ].
	^ nil
]

{ #category : 'printing' }
PikaCharSeqClause >> printOn: aStream [

	printStringCached ifNil: [ printStringCached := '"' , str , '"' ].
	aStream << printStringCached
]

{ #category : 'accessing' }
PikaCharSeqClause >> str [

	^ str
]

{ #category : 'accessing' }
PikaCharSeqClause >> str: anObject [

	str := anObject
]
