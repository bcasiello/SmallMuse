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
		spec package: 'SmallMuse' ]
	

]

{ #category : #accessing }
BaselineOfSmallMuse >> projectClass [
	^ MetacelloCypressBaselineProject
]
