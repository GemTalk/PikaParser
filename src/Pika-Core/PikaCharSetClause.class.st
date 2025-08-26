"
Terminal clause that matches a character or sequence of characters.
"
Class {
	#name : 'PikaCharSetClause',
	#superclass : 'PikaTerminalClause',
	#instVars : [
		'chars',
		'invertedChars'
	],
	#category : 'Pika-Core-clause-terminal',
	#package : 'Pika-Core',
	#tag : 'clause-terminal'
}

{ #category : 'instance creation' }
PikaCharSetClause class >> forCharSets: charSetClauses [

	^ self new
		  initializeForCharSets: charSetClauses;
		  yourself
]

{ #category : 'instance creation' }
PikaCharSetClause class >> forChars: charCollection [

	^ self new
		  initializeForChars: charCollection;
		  yourself
]

{ #category : 'accessing' }
PikaCharSetClause >> chars [

	^ chars
]

{ #category : 'accessing' }
PikaCharSetClause >> chars: anObject [

	chars := anObject
]

{ #category : 'matching' }
PikaCharSetClause >> determineWhetherCanMatchZeroChars [

	^ false
]

{ #category : 'private' }
PikaCharSetClause >> explicitlyMatches: aChar [

	^ chars includes: aChar
]

{ #category : 'private' }
PikaCharSetClause >> implicitlyMatches: aChar [
	"An empty invertedChars does not affect what is matched.
	Non-empty invertedChars will match anything not in invertedChars."

	^ invertedChars notEmpty and: [ (invertedChars includes: aChar) not ]
]

{ #category : 'initialization' }
PikaCharSetClause >> initializeForCharSets: charSetClauses [

	charSetClauses isEmpty ifTrue: [
		self error: 'Must provide at least one CharSetClause' ].
	chars := Set new.
	invertedChars := Set new.
	charSetClauses do: [ :charSet |
		chars addAll: charSet chars.
		invertedChars addAll: charSet invertedChars ]
]

{ #category : 'initialization' }
PikaCharSetClause >> initializeForChars: charCollection [

	chars := Set new.
	invertedChars := Set new.
	chars addAll: charCollection
]

{ #category : 'transformations' }
PikaCharSetClause >> invert [
	"Invert in-place, and answer self"

	| tmp |
	tmp := chars.
	chars := invertedChars.
	invertedChars := tmp.
	self resetPrintString
]

{ #category : 'accessing' }
PikaCharSetClause >> invertedChars [

	^ invertedChars
]

{ #category : 'accessing' }
PikaCharSetClause >> invertedChars: anObject [

	invertedChars := anObject
]

{ #category : 'matching' }
PikaCharSetClause >> matchInput: inputString key: memoKey inTable: memoTable [

	memoKey startPos <= inputString size ifTrue: [
		| c |
		c := inputString at: memoKey startPos.
		((self explicitlyMatches: c) or: [ self implicitlyMatches: c ])
			ifTrue: [ "Terminals are not memoized (i.e. don't look in the memo table)"
				^ PikaMatch memoKey: memoKey len: 1 input: inputString ] ].
	^ nil
]

{ #category : 'private' }
PikaCharSetClause >> printChars: charSet on: outStream inverted: isInverted [

	(isInverted not and: [ charSet size = 1 ])
		ifTrue: [
			outStream nextPut: $'.
			charSet do: [ :char |
				outStream << (PikaStringUtils escapeQuotedChar: char) ].
			outStream nextPut: $' ]
		ifFalse: [
			| sortedStream |
			sortedStream := ReadStream on: charSet sorted.
			outStream << '['.
			isInverted ifTrue: [ outStream << '^' ].


			[ sortedStream atEnd ] whileFalse: [
				| firstChar char nextChar numCharsSpanned |
				firstChar := char := sortedStream next.
				outStream << (PikaStringUtils escapeCharRangeChar: char).
				nextChar := sortedStream peek. "nil if at end"
				[
				nextChar notNil and: [ nextChar codePoint = (char codePoint + 1) ] ]
					whileTrue: [ "contiguous range"
						char := sortedStream next.
						nextChar := sortedStream peek ].
				numCharsSpanned := char codePoint - firstChar codePoint.
				numCharsSpanned > 1 ifTrue: [ outStream << '-' ].
				numCharsSpanned > 0 ifTrue: [
					outStream << (PikaStringUtils escapeCharRangeChar: char) ] ].
			outStream << ']' ]
]

{ #category : 'printing' }
PikaCharSetClause >> printOn: aStream [

	"printStringCached" nil ifNil: [
		| localStream haveChars haveInvertedChars invertedAndNot |
		localStream := WriteStream on: String new.
		haveChars := chars notEmpty.
		haveInvertedChars := invertedChars notEmpty.
		invertedAndNot := haveChars & haveInvertedChars.
		invertedAndNot ifTrue: [ localStream << '(' ].
		haveChars ifTrue: [
			self printChars: chars on: localStream inverted: false ].
		invertedAndNot ifTrue: [ aStream << ' | ' ].
		haveInvertedChars ifTrue: [
			self printChars: invertedChars on: localStream inverted: true ].
		invertedAndNot ifTrue: [ localStream << ')' ].
		printStringCached := localStream contents ].
	aStream << printStringCached
]

{ #category : 'private' }
PikaCharSetClause >> printRangeFrom: charStart to: charEnd on: outStream [

	outStream
		nextPut: charStart;
		nextPut: $-;
		nextPut: charEnd
]
