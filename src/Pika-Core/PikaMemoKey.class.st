"
A memo table key, consisting of a Clause and a match start position.
"
Class {
	#name : 'PikaMemoKey',
	#superclass : 'Object',
	#instVars : [
		'clause',
		'startPos'
	],
	#category : 'Pika-Core-memotable',
	#package : 'Pika-Core',
	#tag : 'memotable'
}

{ #category : 'instance creation' }
PikaMemoKey class >> clause: aClause startPos: positionInteger [

	^ self new
		  clause: aClause;
		  startPos: positionInteger;
		  yourself
]

{ #category : 'comparing' }
PikaMemoKey >> = otherKey [

	self == otherKey ifTrue: [ ^ true ].
	(otherKey isKindOf: PikaMemoKey) ifFalse: [ ^ false ].
	^ clause = otherKey clause and: [ startPos = otherKey startPos ]
]

{ #category : 'accessing' }
PikaMemoKey >> clause [

	^ clause
]

{ #category : 'accessing' }
PikaMemoKey >> clause: anObject [

	clause := anObject
]

{ #category : 'testing' }
PikaMemoKey >> hasMatchedRules [ 
	"Answers true if the matched clause has any rules"
	^ clause hasMatchedRules
]

{ #category : 'comparing' }
PikaMemoKey >> hash [

	^ clause hash bitXor: startPos hash
]

{ #category : 'printing' }
PikaMemoKey >> printClauseOn: aStream [

	clause printOn: aStream
]

{ #category : 'printing' }
PikaMemoKey >> printClauseWithRuleNamesOn: aStream [

	clause printWithRuleNamesOn: aStream
]

{ #category : 'printing' }
PikaMemoKey >> printOn: aStream [

	self printClauseOn: aStream.
	aStream << ' : '.
	self printStartPosOn: aStream
]

{ #category : 'printing' }
PikaMemoKey >> printStartPosOn: aStream [

	startPos printOn: aStream
]

{ #category : 'printing' }
PikaMemoKey >> printStringWithRuleNames [

	| stream |
	stream := WriteStream on: String new.
	self printWithRuleNamesOn: stream.
	^ stream contents
]

{ #category : 'printing' }
PikaMemoKey >> printWithRuleNamesOn: aStream [

	self printClauseWithRuleNamesOn: aStream.
	aStream << ' : '.
	startPos printOn: aStream
]

{ #category : 'accessing' }
PikaMemoKey >> startPos [

	^ startPos
]

{ #category : 'accessing' }
PikaMemoKey >> startPos: anObject [

	startPos := anObject
]
