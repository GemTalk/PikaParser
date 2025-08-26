Class {
	#name : 'PikaStringUtils',
	#superclass : 'Object',
	#category : 'Pika-Core-utils',
	#package : 'Pika-Core',
	#tag : 'utils'
}

{ #category : 'public' }
PikaStringUtils class >> escapeChar: c [
	"Escape a character.
	Answer a string with the (possibly escaped) version of the character"

	| codePoint |
	codePoint := c codePoint.
	(codePoint between: 32 and: 126) ifTrue: [ ^ String with: c ].
	codePoint = 10 ifTrue: [ ^ '\n' ].
	codePoint = 13 ifTrue: [ ^ '\r' ].
	codePoint = 9 ifTrue: [ ^ '\t' ].
	codePoint = 12 ifTrue: [ ^ '\f' ].
	codePoint = 8 ifTrue: [ ^ '\b' ].
	^ '\u' , (codePoint printStringBase: 16 length: 4 padded: true)
]

{ #category : 'public' }
PikaStringUtils class >> escapeCharRangeChar: c [
	"Escape a character for inclusion in a character range pattern.
	Answer a String containing the (possibly escaped) representation of Character c"

	c = $] ifTrue: [ ^ '\]' ].
	c = $^ ifTrue: [ ^ '\^' ].
	c = $- ifTrue: [ ^ '\-' ].
	c = $\ ifTrue: [ ^ '\\' ].
	^ self escapeChar: c
]

{ #category : 'public' }
PikaStringUtils class >> escapeQuotedChar: c [
	"Escape a single-quoted character.
	Answer a string that is the escaped version of c"

	c = $' ifTrue: [ ^ '\''' ].
	c = $\ ifTrue: [ ^ '\\' ].
	^ self escapeChar: c
]

{ #category : 'public' }
PikaStringUtils class >> escapeQuotedStringChar: c [
	"Answer a string with the (possibly escaped) version of Character c"

	c = $" ifTrue: [ ^ '\"' ].
	c = $\ ifTrue: [ ^ '\' ].
	^ self escapeChar: c
]

{ #category : 'public' }
PikaStringUtils class >> escapeString: str [

	| buf |
	buf := WriteStream on: (String new: str size).
	str do: [ :c |
		buf << (c = $"
			 ifTrue: [ '\"' ]
			 ifFalse: (self escapeQuotedStringChar: c)) ].
	^ buf contents
]

{ #category : 'public' }
PikaStringUtils class >> getCharRangeCharsOf: str [
	"Get the sequence of (possibly escaped) characters in a char range string, 
	and answer an OrderedCollection of Strings, each of which is or represents (through escaping) 
	a single character. "

	| charRangeChars i |
	charRangeChars := OrderedCollection new.
	i := 0.
	[ i < str size ] whileTrue: [
		| c |
		i := i + 1.
		c := str at: i.
		c = $\
			ifTrue: [
				i = str size ifTrue: [
					self error: 'Got backslash at end of quoted string' ].
				(str at: i + 1) = $u
					ifTrue: [
						i > (str size - 5) ifTrue: [
							self error: 'Truncated Unicode character sequence' ].
						charRangeChars add:
							(String with: (self unescapeChar: (str copyFrom: i to: i + 5))).
						i := i + 5 "Consume escaped character" ]
					ifFalse: [
						| escapeSeq |
						escapeSeq := str copyFrom: i to: i + 1.
						(((escapeSeq = '\-' or: [ escapeSeq = '\^' ]) or: [
							  escapeSeq = '\]' ]) or: [ escapeSeq = '\\' ])
							ifTrue: [ "Preserve range-specific escaping for char ranges"
								charRangeChars add: escapeSeq ]
							ifFalse: [
							charRangeChars add:
								(String with: (self unescapeChar: escapeSeq)) ].
						i := i + 1 "Consume escaped character" ] ]
			ifFalse: [ charRangeChars add: (String with: c) ] ].
	^ charRangeChars
]

{ #category : 'private' }
PikaStringUtils class >> nonAsciiChar [

	^ $■
]

{ #category : 'public' }
PikaStringUtils class >> replaceNonAsciiForChar: char [

	^ (char codePoint between: 32 and: 126)
		  ifTrue: [ char ]
		  ifFalse: [ self nonAsciiChar ]
]

{ #category : 'public' }
PikaStringUtils class >> replaceNonAsciiIn: string [

	| stream |
	stream := WriteStream on: (String new: string size).
	self replaceNonAsciiIn: string toStream: stream.
	^ stream contents
]

{ #category : 'public' }
PikaStringUtils class >> replaceNonAsciiIn: string toStream: stream [

	string do: [ :c | stream nextPut: (self replaceNonAsciiForChar: c) ]
]

{ #category : 'public' }
PikaStringUtils class >> unescapeChar: escapedChar [
	"escapedChar is a string, apparently because Java :-/ 
	Answered value is a Character"

	escapedChar ifEmpty: [ ^ self error: 'Empty char string' ].
	escapedChar size = 1 ifTrue: [ ^ escapedChar first ].
	escapedChar = '\t' ifTrue: [ ^ Character tab ].
	escapedChar = '\b' ifTrue: [ ^ Character backspace ].
	escapedChar = '\n' ifTrue: [ ^ Character lf ].
	escapedChar = '\r' ifTrue: [ ^ Character cr ].
	escapedChar = '\f' ifTrue: [ ^ Character codePoint: 12 ].
	escapedChar = '\''' ifTrue: [ ^ $' ].
	escapedChar = '\"' ifTrue: [ ^ $" ].
	escapedChar = '\\' ifTrue: [ ^ $\ ].

	((escapedChar beginsWith: '\u') and: [ escapedChar size = 6 ])
		ifTrue: [
			^ Character codePoint:
				  (Number readFrom: (escapedChar copyFrom: 3 to: 6) base: 16) ].
	self error: 'Invalid character: ' , escapedChar
]

{ #category : 'public' }
PikaStringUtils class >> unescapeString: str [
	"Unescape a string"

	| buf i |
	buf := WriteStream on: String new.
	i := 0.
	[ i < str size ] whileTrue: [
		| c |
		i := i + 1.
		c := str at: i.
		c = $\
			ifTrue: [
				i = str size ifTrue: [
					self error: 'Got backslash at end of quoted string' ].
				(str at: i + 1) = $u
					ifTrue: [
						i > (str size - 5) ifTrue: [
							self error: 'Truncated Unicode character sequence' ].
						buf nextPut: (self unescapeChar: (str copyFrom: i to: i + 5)).
						i := i + 5 "Consume escaped characters" ]
					ifFalse: [
						| escapeSeq |
						escapeSeq := str copyFrom: i to: i + 1.
						buf nextPut: (self unescapeChar: escapeSeq).
						i := i + 1 ] ]
			ifFalse: [ buf nextPut: c ] ].
	^ buf contents
]
