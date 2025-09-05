"
Abstract class for parsing some string to some object model.
A concrete subclass must provide the source code of a grammar. The resulting grammar object will be used to produce an abstract syntax tree.
A subclass must provide method for each AST node type, which does whatever is necessary to convert that AST node to an object for the model for that grammar. 
"
Class {
	#name : 'PikaParser',
	#superclass : 'Object',
	#classInstVars : [
		'grammar'
	],
	#category : 'Pika-Parser',
	#package : 'Pika-Parser'
}

{ #category : 'accessing' }
PikaParser class >> grammar [

	^ grammar ifNil: [ self initializeGrammar ]
]

{ #category : 'as yet unclassified' }
PikaParser class >> grammarSource [
	"Should answer a string specifying the source code of a Pika PEG parser."

	self subclassResponsibility
]

{ #category : 'initialization' }
PikaParser class >> initializeGrammar [
	"self initializeGrammar"

	"This needs to be done whenever the source of the grammar is changed."

	^ grammar := PikaMetaGrammar parse: self grammarSource
]
