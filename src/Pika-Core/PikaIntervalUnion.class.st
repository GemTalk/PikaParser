Class {
	#name : 'PikaIntervalUnion',
	#superclass : 'Object',
	#instVars : [
		'nonOverlappingRanges'
	],
	#category : 'Pika-Core-utils',
	#package : 'Pika-Core',
	#tag : 'utils'
}

{ #category : 'adding' }
PikaIntervalUnion >> addRangeStartPos: startPos endPos: endPos [
	"Add a range to a union of ranges.
	startPos is the index of the first char of a match,
	endPos is startPos + match len, so the index one past the last char of the match."

	| overlappingRanges newStart newEnd |
	overlappingRanges := self
		                     rangesOverlappingStart: startPos
		                     end: endPos.
	newStart := startPos.
	newEnd := endPos.
	overlappingRanges isEmpty ifFalse: [
		newStart := newStart min: overlappingRanges first key.
		newEnd := newEnd max: overlappingRanges last value ].
	overlappingRanges do: [ :each |
		nonOverlappingRanges removeKey: each key ].
	nonOverlappingRanges at: newStart put: newEnd
]

{ #category : 'testing' }
PikaIntervalUnion >> doesRangeOverlapStart: startPos end: endPos [

	nonOverlappingRanges
		associationAtOrBefore: startPos
		ifPresent: [ :lowRange |
			lowRange value > startPos
				ifTrue: [ ^ true ]
				ifFalse: [
					| highRange |
					highRange := lowRange next.
					highRange ifNotNil: [
						^ highRange key between: startPos and: endPos - 1 ] ] ]
		ifAbsent: [
			nonOverlappingRanges firstAssociationIfPresent: [ :firstRange |
				^ firstRange key between: startPos and: endPos - 1 ] ].
	^ false
]

{ #category : 'initializing' }
PikaIntervalUnion >> initialize [

	super initialize.
	nonOverlappingRanges := SkipList new
]

{ #category : 'accessing' }
PikaIntervalUnion >> invertStartPos: startPos endPos: endPos [
	"Get the inverse of the intervals in this set within [StartPos, endPos).
	That is, every element between startPos and endPos that I do *not* contain."

	| invertedIntervalSet overlappingRanges prevInterval firstOverlapStart lastOverlapEnd |
	invertedIntervalSet := PikaIntervalUnion new.
	overlappingRanges := self
		                     rangesOverlappingStart: startPos
		                     end: endPos.
	overlappingRanges ifEmpty: [
		invertedIntervalSet addRangeStartPos: startPos endPos: endPos.
		^ invertedIntervalSet ].
	prevInterval := overlappingRanges first.
	firstOverlapStart := prevInterval key.
	firstOverlapStart > startPos ifTrue: [
		invertedIntervalSet
			addRangeStartPos: startPos
			endPos: firstOverlapStart ].
	"We know that each element of overlappingRanges has at least one element between each element."
	prevInterval := overlappingRanges first.
	2 to: overlappingRanges size do: [ :i |
		| thisInterval |
		thisInterval := overlappingRanges at: i.
		invertedIntervalSet
			addRangeStartPos: prevInterval value
			endPos: thisInterval key.
		prevInterval := thisInterval ].
	lastOverlapEnd := prevInterval value.
	lastOverlapEnd < endPos ifTrue: [
		invertedIntervalSet addRangeStartPos: lastOverlapEnd endPos: endPos ].
	^ invertedIntervalSet
]

{ #category : 'accessing' }
PikaIntervalUnion >> nonOverlappingRanges [

	^ nonOverlappingRanges
]

{ #category : 'private' }
PikaIntervalUnion >> rangesOverlappingStart: start end: end [
	"Answer an ordered collection of my associations describing 
	the ranges that overlap or are immediately adjacent to
	the range defined by start -> end,
	where end is an index one past the end,
	i.e. the range 1 -> 5 has a length of four, 
	and would be adjacent to, not overlapping with,
	the range 5 -> 10."

	| result node |
	result := OrderedCollection new.
	node := nonOverlappingRanges
		        associationAtOrBefore: start
		        ifPresent: [ :lowNode |
			        lowNode value >= start ifTrue: [ result add: lowNode ].
			        lowNode ]
		        ifAbsent: [
			        nonOverlappingRanges
				        firstAssociationIfPresent: [ :firstNode |
					        (firstNode key between: start and: end)
						        ifTrue: [
							        result add: firstNode.
							        firstNode ]
						        ifFalse: [ firstNode ] ]
				        ifAbsent: [ "No ranges, no overlap" ^ result ] ].

	[
	node := node next.
	node notNil and: [ node key <= end ] ] whileTrue: [ result add: node ].
	^ result
]
