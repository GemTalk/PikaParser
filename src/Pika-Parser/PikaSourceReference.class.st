"
Represents a variety of information about the specific location of the source code for a node. This is used in generating debugging informatin in DWARF format (and possibly enhanced with other formats in the future).

I have the ability to store multiple source ranges for a single point in the source. Since both Smalltalk and Dew source use multi-keyword messages, it is desirable for a debugger to highlight all of the keywords of a message about to be sent or an instruction about to be executed.

I also keep information about filename, file path, line number, and column, since that is the default that DWARF-driven debuggers like GDB use.
"
Class {
	#name : 'PikaSourceReference',
	#superclass : 'Object',
	#instVars : [
		'lineNumber',
		'columnNumber',
		'sourceString',
		'ranges',
		'fileReference'
	],
	#category : 'Pika-Parser',
	#package : 'Pika-Parser'
}

{ #category : 'adding' }
PikaSourceReference >> addRangeStartPos: start endPos: end [
	"The ranges added this way should be disjoint."

	ranges at: start put: end
]

{ #category : 'accessing' }
PikaSourceReference >> columnNumber [

	^ columnNumber
]

{ #category : 'accessing' }
PikaSourceReference >> columnNumber: anObject [

	columnNumber := anObject
]

{ #category : 'accessing' }
PikaSourceReference >> fileReference [

	^ fileReference
]

{ #category : 'accessing' }
PikaSourceReference >> fileReference: anObject [

	fileReference := anObject
]

{ #category : 'initialization' }
PikaSourceReference >> initialize [

	ranges := SkipList new
]

{ #category : 'accessing' }
PikaSourceReference >> lineNumber [

	^ lineNumber
]

{ #category : 'accessing' }
PikaSourceReference >> lineNumber: anObject [

	lineNumber := anObject
]

{ #category : 'printing' }
PikaSourceReference >> printOn: aStream [

	aStream
		<< '(line:';
		print: lineNumber;
		<< ' col:';
		print: columnNumber.

	ranges keysAndValuesDo: [ :k :v |
		aStream
			space;
			print: k;
			<< ':';
			print: v ].
	aStream << ')'
]

{ #category : 'adding' }
PikaSourceReference >> rangesDo: aBlock [
	"Evaluate the block with each of the start and end values of my ranges, in order."

	ranges keysAndValuesDo: aBlock
]

{ #category : 'accessing' }
PikaSourceReference >> sourceString [

	^ sourceString
]

{ #category : 'accessing' }
PikaSourceReference >> sourceString: anObject [

	sourceString := anObject
]
