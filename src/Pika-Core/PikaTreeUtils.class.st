Class {
	#name : 'PikaTreeUtils',
	#superclass : 'Object',
	#category : 'Pika-Core-utils',
	#package : 'Pika-Core',
	#tag : 'utils'
}

{ #category : 'printing' }
PikaTreeUtils class >> printTreeViewOfMatch: match input: input [

	| stdout |
	stdout := ZnCharacterWriteStream
		          on: (ZnBufferedWriteStream on: Stdio stdout)
		          encoding: 'utf8'.
	self
		renderTreeViewOfMatch: match
		on: stdout
		astNodeLabel: nil
		input: input
		indentStr: ''
		isLastChild: true.
	stdout flush
]

{ #category : 'rendering' }
PikaTreeUtils class >> renderAstTreeView: astNode input: input indentStr: indentStr isLastChild: isLastChild on: stream [
	"Render the AST rooted at an ASTNode onto a stream."

	| inpLen inp |
	inpLen := 80.
	inp := input
		       copyFrom: astNode startPos
		       to:
		       (input size min:
			        astNode startPos + (astNode len min: inpLen) - 1).
	inp size = inpLen ifTrue: [ inp := inp , '...' ].
	inp := PikaStringUtils escapeString: inp.

	"Uncomment for double-spaced rows"
	" buf.append(indentStr + ""│\n"");"

	stream
		<< indentStr;
		<< (isLastChild
				 ifTrue: [ '└─' ]
				 ifFalse: [ '├─' ]);
		<< (astNode label ifNil: [ '<root>' ]);
		<< ' : ';
		<< astNode startPos printString;
		<< '+';
		<< astNode len printString;
		<< ' : "';
		<< inp;
		<< '"';
		lf.
	1 to: astNode children size do: [ :i |
		self
			renderAstTreeView: (astNode children at: i)
			input: input
			indentStr: indentStr , (isLastChild
					 ifTrue: [ '  ' ]
					 ifFalse: [ '│ ' ])
			isLastChild: i = astNode children size
			on: stream ]
]

{ #category : 'rendering' }
PikaTreeUtils class >> renderTreeViewOfMatch: match on: outStream astNodeLabel: astNodeLabel input: input indentStr: indentStr isLastChild: isLastChild [
	"Render a parse tree rooted at a Match node onto a Stream."

	| inpLen inp astNodeLabelNeedsParens ruleNames subClauseMatchesToUse |
	inpLen := 80.


	inp := input
		       copyFrom: match memoKey startPos
		       to:
		       (input size min:
			        match memoKey startPos + (match len - 1 min: inpLen)).
	inp size = inpLen ifTrue: [ inp := inp , '...' ].
	inp := PikaStringUtils escapeString: inp.

	"Uncomment for double-spaced rows"
	"buf.append(indentStr + ""│\n"");"

	astNodeLabelNeedsParens := PikaMetaGrammar
		                           needToAddParensAroundAstNodeLabelOfClause:
		                           match memoKey clause.
	outStream
		<< indentStr;
		<< (isLastChild
				 ifTrue: [ '└─' ]
				 ifFalse: [ '├─' ]).
	ruleNames := match memoKey clause ruleNames.
	ruleNames ifNotEmpty: [
		outStream
			<< ruleNames;
			<< ' <- ' ].
	astNodeLabel ifNotNil: [
		outStream << astNodeLabel.
		astNodeLabelNeedsParens ifTrue: [ outStream << '(' ] ].

	match memoKey clause printOn: outStream.
	astNodeLabel ifNotNil: [
		astNodeLabelNeedsParens ifTrue: [ outStream << ')' ] ].
	outStream
		<< ' : ';
		<< match memoKey startPos printString;
		<< '+';
		<< match len printString;
		<< ' : "';
		<< inp;
		<< '"';
		lf.

	"Recurse to descendants"
	subClauseMatchesToUse := match getSubClauseMatches.
	1 to: subClauseMatchesToUse size do: [ :subClauseMatchIdx |
		| subClauseMatchEnt subClauseASTNodeLabel subClauseMatch |
		subClauseMatchEnt := subClauseMatchesToUse at: subClauseMatchIdx.
		subClauseASTNodeLabel := subClauseMatchEnt key.
		subClauseMatch := subClauseMatchEnt value.
		self
			renderTreeViewOfMatch: subClauseMatch
			on: outStream
			astNodeLabel: subClauseASTNodeLabel
			input: input
			indentStr: indentStr , (isLastChild
					 ifTrue: [ '  ' ]
					 ifFalse: [ '│ ' ])
			isLastChild: subClauseMatchIdx = subClauseMatchesToUse size ]
]
