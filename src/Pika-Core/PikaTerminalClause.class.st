"
Abstract. The superclass of all terminal clauses.
"
Class {
	#name : 'PikaTerminalClause',
	#superclass : 'PikaClause',
	#category : 'Pika-Core-clause-terminal',
	#package : 'Pika-Core',
	#tag : 'clause-terminal'
}

{ #category : 'instance creation' }
PikaTerminalClause class >> new [

	^ super new
		  initializeWithSubClauses: {  };
		  yourself
]

{ #category : 'testing' }
PikaTerminalClause >> isTerminal [

	^ true
]
