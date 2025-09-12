"
Abstract class for parsing some string to some object model.
A concrete subclass must provide the source code of a grammar. The resulting grammar object will be used to produce an abstract syntax tree.
A subclass must provide method for each AST node type, which does whatever is necessary to convert that AST node to an object for the model for that grammar. 
"
Class {
	#name : 'PikaParser',
	#superclass : 'Object',
	#instVars : [
		'memoTable',
		'lineTable',
		'fileReference',
		'startOffset'
	],
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

{ #category : 'support' }
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

{ #category : 'private' }
PikaParser >> assert: astNode hasLabel: label [

	astNode label = label ifFalse: [
		self error:
			'Expected AST node labeled ' , label printString , ' but got '
			, astNode label printString ]
]

{ #category : 'private' }
PikaParser >> assert: astNode hasLabel: label numChildren: numChildren [

	self
		assert: astNode hasLabel: label;
		assert: astNode hasNumChildren: numChildren
]

{ #category : 'private' }
PikaParser >> assert: astNode hasNumChildren: numChildren [

	astNode children size = numChildren ifFalse: [
		self error: 'Expected AST node to have ' , numChildren printString
			, ' children but ' , astNode children size printString
			, ' children found' ]
]

{ #category : 'accessing' }
PikaParser >> grammar [

	^ self class grammar
]

{ #category : 'parsing' }
PikaParser >> parse: sourceString [
	"Parse the given string. The locations in the result will
	claim to come from a FileReference named 'None' and starting 
	at offset 1 within that non-file."

	^ self
		  parse: sourceString
		  fromFile: 'None' asFileReference
		  atOffset: 1
]

{ #category : 'parsing' }
PikaParser >> parse: sourceString fromFile: aFileReference atOffset: offset [
	"Parse the given string. The locations in the result will
	claim to come from the FileReference starting at one-base offset 'offset'. 
	The FileReference need not exist."

	fileReference := aFileReference.
	startOffset := offset.
	^ self privateParse: sourceString
]

{ #category : 'parsing' }
PikaParser >> parseFile: aFileReference [
	"Parse the entire contents of the file, which must exist."

	^ self
		  parse: aFileReference contents
		  fromFile: aFileReference
		  atOffset: 1
]

{ #category : 'private' }
PikaParser >> parseToAst: sourceString [

	memoTable := self grammar parse: sourceString.
	self reportSyntaxErrors.
	^ memoTable ast
]

{ #category : 'private' }
PikaParser >> privateParse: sourceString [
	"parse the given source, and answer the root object of a model tree.
	Or signal an exception if the source is not valid."

	| astRoot |
	lineTable := PikaLineNumberTable forSource: sourceString.
	astRoot := self parseToAst: sourceString.
	self assert: astRoot hasNumChildren: 1.
	^ self visitAstNode: astRoot
]

{ #category : 'private' }
PikaParser >> reportSyntaxErrors [

	| syntaxErrors |
	syntaxErrors := memoTable syntaxErrorsForRuleNames:
		                self syntaxCoverageRules.
	syntaxErrors ifNotEmpty: [ ^ self error: 'syntax errors' ]
]

{ #category : 'private' }
PikaParser >> setSourceLocationOf: modelNode from: astNode [

	| sourceRef lineAndColumn startPos endPos |
	"If sourceReference already set by an inner AST node, keep that as being more accurate."
	modelNode sourceReference ifNotNil: [ ^ self ].
	startPos := astNode startPos.
	endPos := startPos + astNode len - 1.
	lineAndColumn := lineTable lineAndColumnForPosition: startPos.
	sourceRef := PikaSourceReference new
		             fileReference: fileReference;
		             lineNumber: lineAndColumn key;
		             columnNumber: lineAndColumn value;
		             sourceString: memoTable input;
		             addRangeStartPos: startPos endPos: endPos;
		             yourself.
	modelNode sourceReference: sourceRef
]

{ #category : 'testing' }
PikaParser >> shouldRecordSourceLocations [

	^ true
]

{ #category : 'private' }
PikaParser >> syntaxCoverageRules [
	"This method should answer a collection of rule names that, between them, should cover all input text."

	self subclassResponsibility
]

{ #category : 'accessing' }
PikaParser >> syntaxErrorReport [

	| syntaxErrors text |
	syntaxErrors := memoTable syntaxErrorsForRuleNames:
		                self syntaxCoverageRules.
	syntaxErrors ifEmpty: [ ^ 'No syntax errors found' ].

	"Inspect source with syntax error ranges bolded and in red."
	text := memoTable input asText.
	syntaxErrors keysAndValuesDo: [ :start :v |
		| end |
		end := v key - 1.
		text
			makeBoldFrom: start to: end;
			makeColor: Color red from: start to: end ].
	text inspect
]

{ #category : 'private' }
PikaParser >> visitAstNode: astNode [

	| selector modelNode |
	selector := (astNode label , ':') asSymbol.
	modelNode := self perform: selector with: astNode.
	self shouldRecordSourceLocations ifTrue: [
		self setSourceLocationOf: modelNode from: astNode ].
	^ modelNode
]
