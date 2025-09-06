"
For a given source string, computes and makes available information about how character offsets within the source string relate to lines and columns in the file.
"
Class {
	#name : 'PikaLineNumberTable',
	#superclass : 'Object',
	#instVars : [
		'source',
		'table'
	],
	#category : 'Pika-Parser',
	#package : 'Pika-Parser'
}

{ #category : 'instance creation' }
PikaLineNumberTable class >> forSource: sourceString [

	^ self new
		  sourceString: sourceString;
		  yourself
]

{ #category : 'queries' }
PikaLineNumberTable >> lineAndColumnForPosition: pos [
	"Answer an Association of lineNumber > columnNumber for the given position in my source string.
	lineNumber, columnNumber, and pos are all 1-based."

	| lineStartAndNumber |
	lineStartAndNumber := table
		                      associationAtOrBefore: pos
		                      ifAbsent: [
		                      self error: 'position out of range -- < 1?' ].
	^ lineStartAndNumber value -> (pos - lineStartAndNumber key + 1)
]

{ #category : 'accessing' }
PikaLineNumberTable >> sourceString: aString [
	"Accepted line ends are CR, LF, or CRLF."

	| stream lineNo cr lf |
	source := aString.
	stream := ReadStream on: source.
	lineNo := 1.
	cr := Character cr.
	lf := Character lf.
	table := SkipList new.
	[ stream atEnd ] whileFalse: [
		| char |
		table at: stream position + 1 put: lineNo.
		[
		char := stream next.
		(char == cr or: [ char == lf ]) or: [ stream atEnd ] ] whileFalse.
		stream atEnd ifTrue: [ ^ self ].
		(char == cr and: [ stream peek == lf ]) ifTrue: [ stream next ].
		"Stream now positioned just before the first char of the next line."
		lineNo := lineNo + 1 ]
]
