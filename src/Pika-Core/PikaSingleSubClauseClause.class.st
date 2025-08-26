"
Abstract parent of non-terminal clause classes that have only one subclause.
"
Class {
	#name : 'PikaSingleSubClauseClause',
	#superclass : 'PikaClause',
	#category : 'Pika-Core-clause-nonterminal',
	#package : 'Pika-Core',
	#tag : 'clause-nonterminal'
}

{ #category : 'as yet unclassified' }
PikaSingleSubClauseClause class >> withSubClause: aClause [

	^ self withSubClauses: { aClause }
]

{ #category : 'testing' }
PikaSingleSubClauseClause >> doesOneOrMoreOfMeHaveAnEffect [

	^ false
]

{ #category : 'accessing' }
PikaSingleSubClauseClause >> labeledSubClause [
	^ labeledSubClauses first
]

{ #category : 'accessing' }
PikaSingleSubClauseClause >> subClause [

	^ self labeledSubClause clause
]
