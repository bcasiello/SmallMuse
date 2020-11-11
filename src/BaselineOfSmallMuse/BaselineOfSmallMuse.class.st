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
	spec for: #common do: [ "Packages"
		spec package: 'SmallMuse'.
		spec group: 'default' with: #( 'FileDialog' ) ]
]

{ #category : #accessing }
BaselineOfSmallMuse >> projectClass [
	^ MetacelloCypressBaselineProject
]
