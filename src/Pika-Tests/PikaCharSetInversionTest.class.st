Class {
	#name : 'PikaCharSetInversionTest',
	#superclass : 'TestCase',
	#category : 'Pika-Tests',
	#package : 'Pika-Tests'
}

{ #category : 'tests' }
PikaCharSetInversionTest >> testCharSetInversion [

	| grammar memoTable |
	grammar := PikaMetaGrammar parse:
		           'P <- C+; C <- "//" [^\r\n]* [\r\n]?;'.
	memoTable := grammar parse:
		             '// xyz' , (String with: Character lf) , '//'.
	self
		assert: (memoTable syntaxErrorsForRuleNames: { 'P'. 'C' }) size
		equals: 0
]
