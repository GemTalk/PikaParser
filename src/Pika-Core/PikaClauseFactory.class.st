"
Clause factory, enabling the construction of clauses without ""new"", using static imports.

"
Class {
	#name : 'PikaClauseFactory',
	#superclass : 'Object',
	#category : 'Pika-Core-utils',
	#package : 'Pika-Core',
	#tag : 'utils'
}

{ #category : 'factory' }
PikaClauseFactory class >> anything [
	"Construct an Any terminal"

	^ PikaAnyClause new
]

{ #category : 'factory' }
PikaClauseFactory class >> astLabeled: astNodeLabel clause: clause [
	"Construct an AstNodeLabel"

	^ PikaAstNodeLabel label: astNodeLabel clause: clause
]

{ #category : 'factory' }
PikaClauseFactory class >> cInStr: str [
	"Construct a terminal that matches one instance of 
	any character in a given string or array of Characters."

	^ PikaCharSetClause forChars: str
]

{ #category : 'factory' }
PikaClauseFactory class >> cRangeFrom: minChar to: maxChar [
	"Construct a terminal that matches a character range."

	| chars |
	maxChar < minChar ifTrue: [ self error: 'maxChar < minChar' ].
	chars := OrderedCollection new:
		         maxChar codePoint - minChar codePoint + 1.
	minChar codePoint to: maxChar codePoint do: [ :i |
	chars add: (Character codePoint: i) ].
	^ PikaCharSetClause forChars: chars
]

{ #category : 'factory' }
PikaClauseFactory class >> cRangeStr: charRangeStr [
	"Construct a terminal that matches a character range, specified using 
	regexp notation without the square brackets."

	| invert charList chars i charSet |
	invert := charRangeStr first = $^.
	charList := PikaStringUtils getCharRangeCharsOf: (invert
			             ifTrue: [
			             charRangeStr copyFrom: 2 to: charRangeStr size ]
			             ifFalse: [ charRangeStr ]).
	chars := Set new.
	i := 0.
	[ i < charList size ] whileTrue: [
		| c c0 |
		i := i + 1.
		c := charList at: i.
		c size = 2 ifTrue: [ "Unescape \^, \-, \], \\"
			c := c copyFrom: 2 to: 2 ].
		c0 := c first.
		(i <= (charList size - 2) and: [ (charList at: i + 1) = '-' ])
			ifTrue: [
				| cEnd cEnd0 |
				cEnd := charList at: i + 2.
				cEnd size = 2 ifTrue: [ "Unescape \^, \-, \], \\"
					cEnd := cEnd copyFrom: 2 to: 2 ].
				cEnd0 := cEnd first.
				cEnd0 < c0 ifTrue: [
					self error:
						'Char range limits out of order: ' , c0 printString , ', '
						, cEnd0 printString ].
				c0 codePoint to: cEnd0 codePoint do: [ :j |
				chars add: (Character codePoint: j) ].
				i := i + 2 ]
			ifFalse: [ chars add: c0 ] ].
	charSet := PikaCharSetClause forChars: chars.
	^ invert
		  ifTrue: [ charSet invert ]
		  ifFalse: [ charSet ]
]

{ #category : 'factory' }
PikaClauseFactory class >> cSets: charSets [
	"Construct a character set as the union of other character sets."

	^ PikaCharSetClause forCharSets: charSets
]

{ #category : 'accessing' }
PikaClauseFactory class >> first: subClauses [
	"Construct a First clause"

	^ PikaFirstClause withSubClauses: subClauses
]

{ #category : 'factory' }
PikaClauseFactory class >> followedBy: subClause [

	subClause isNothingClause ifTrue: [ "FollowedBy(Nothing) -> Nothing (since Nothing always matches)"
		^ subClause ].
	subClause makesSenseForFollowedBy ifFalse: [
		^ self error:
			  PikaFollowedByClause name , '(' , subClause class name
			  , ') is nonsensical' ].
	^ PikaFollowedByClause withSubClause: subClause
]

{ #category : 'factory' }
PikaClauseFactory class >> notFollowedBy: subClause [
	"Construct a NotFollowedBy clause"

	subClause isNothingClause ifTrue: [
		^ self error:
			  PikaNotFollowedByClause class name , '(' , PikaNothingClause name
			  , ') will never match anything' ].
	subClause isNotFollowedByClause ifTrue: [ "Doubling NotFollowedBy yields FollowedBy.
            N.B. this will not catch the case of ""X <- !Y; Y <- !Z;"", since RuleRefs are
            not resolved yet"
		^ PikaFollowedByClause withSubClause:
			  subClause labeledSubClauses first clause ].
	subClause makesSenseForNotFollowedBy ifFalse: [
		self error:
			PikaNotFollowedByClause name , '(' , subClause class name
			, ') is nonsensical' ].
	^ PikaNotFollowedByClause withSubClause: subClause
]

{ #category : 'factory' }
PikaClauseFactory class >> nothing [
	"Construct a Nothing terminal"

	^ PikaNothingClause new
]

{ #category : 'factory' }
PikaClauseFactory class >> oneOrMore: subClause [
	"Construct a OneOrMore clause"

	"It doesn't make sense to wrap some clause types in OneOrMore, but the OneOrMore should have
	no effect if this does occur in the grammar, so remove it"

	^ subClause doesOneOrMoreOfMeHaveAnEffect
		  ifTrue: [ PikaOneOrMoreClause withSubClause: subClause ]
		  ifFalse: [ subClause ]
]

{ #category : 'factory' }
PikaClauseFactory class >> optional: subClause [
	"Construct an Optional clause"

	"Optional(X) -> First(X, Nothing)"

	^ self first: {
			  subClause.
			  self nothing }
]

{ #category : 'factory' }
PikaClauseFactory class >> ruleNamed: ruleName clause: clause [
	"Construct a Rule"

	"Use -1 as precedence if rule group has only one precedence"

	^ self
		  ruleNamed: ruleName
		  precedence: -1
		  associativity: nil
		  clause: clause
]

{ #category : 'factory' }
PikaClauseFactory class >> ruleNamed: ruleName precedence: precedence associativity: associativity clause: clause [
	"Construct a {@link Rule} with the given precedence and associativity."

	^ PikaRule
		  named: ruleName
		  precedence: precedence
		  associativity: associativity
		  clause: clause
]

{ #category : 'factory' }
PikaClauseFactory class >> ruleRefTo: ruleName [
	"Construct a RuleRef"

	^ PikaRuleRef withRuleName: ruleName
]

{ #category : 'factory' }
PikaClauseFactory class >> seq: subClauses [
	"Construct s Seq clause"

	^ PikaSeqClause withSubClauses: subClauses
]

{ #category : 'factory' }
PikaClauseFactory class >> start [
	"Construct a Start terminal"

	^ PikaStartClause new
]

{ #category : 'factory' }
PikaClauseFactory class >> str: str [
	"Construct a terminal that matches a string token."

	str size = 1 ifTrue: [ ^ self cInStr: str ].
	^ PikaCharSeqClause string: str ignoreCase: false
]

{ #category : 'factory' }
PikaClauseFactory class >> zeroOrMore: subClause [
	"Construct a ZeroOrMore clause"

	"ZeroOrMore(X) => Optional(OneOrMore(X)) => First(OneOrMore(X), Nothing)"

	^ self optional: (self oneOrMore: subClause)
]
