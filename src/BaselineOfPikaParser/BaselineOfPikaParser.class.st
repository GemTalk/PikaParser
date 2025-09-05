Class {
	#name : 'BaselineOfPikaParser',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPikaParser',
	#package : 'BaselineOfPikaParser'
}

{ #category : 'baselines' }
BaselineOfPikaParser >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			package: 'Pika-Core' with: [ spec requires: #( 'SkipList' ) ];
			package: 'Pika-Tests' with: [ spec requires: #( 'Pika-Core' ) ];
			package: 'Pika-Parser' with: [ spec requires: #( 'Pika-Core' ) ].
		spec
			group: 'default' with: #( 'Dev' );
			group: 'Dev' with: #( 'Core' 'Tests' );
			group: 'Core' with: #( 'Pika-Core' );
			group: 'Tests' with: #( 'Pika-Tests' ).
		spec
			baseline: 'SkipList'
			with: [ spec repository: self skipListUrl ] ]
]

{ #category : 'support' }
BaselineOfPikaParser >> skipListUrl [

	^ self urlForProject: 'SkipList'
]

{ #category : 'support' }
BaselineOfPikaParser >> urlForProject: projectName [

	| projectsHome path |
	projectsHome := OSEnvironment current
		                at: 'ROWAN_PROJECTS_HOME'
		                ifAbsent: [
			                ^ self error:
				                  'ROWAN_PROJECTS_HOME must be set to find local projects' ].
	path := Path / projectsHome / projectName / 'src'.
	^ path asFileReference exists
		  ifFalse: [ self error: 'Cannot find ' , path ]
		  ifTrue: [ 'gitlocal://' , path pathString ]
]
