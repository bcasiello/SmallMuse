"
Baseline definitions for SmallMuse
"
Class {
	#name : #BaselineOfSmallMuse,
	#superclass : #BaselineOf,
	#category : #BaselineOfSmallMuse
}

{ #category : #baselines }
BaselineOfSmallMuse >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			baseline: 'Mustache'
			with: [ spec repository: 'github://noha/mustache:master/src' ];
			baseline: 'TinyLogger'
			with: [ spec repository: 'github://jecisc/TinyLogger:v1.x.x/src' ];
			package: 'SmallMuse' ]
]
