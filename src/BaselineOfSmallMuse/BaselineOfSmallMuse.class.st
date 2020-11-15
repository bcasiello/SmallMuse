"
Baseline definitions for SmallMuse
"
Class {
	#name : #BaselineOfSmallMuse,
	#superclass : #BaselineOf,
	#category : #BaselineOfSmallMuse
}

{ #category : #'as yet unclassified' }
BaselineOfSmallMuse >> ZincHTTPComponents: spec [ [
	spec
		project: 'ZincHTTPComponents'
		with: [ spec
			className: #ConfigurationOfZincHTTPComponents;
			repository: 'http://smalltalkhub.com/mc/SvenVanCaekenberghe/ZincHTTPComponents/main/' ]
]
]

{ #category : #baselines }
BaselineOfSmallMuse >> baseline: spec [
	<baseline>
	spec for: #common do: [
		"Dependencies"
		self ZincHTTPComponents: spec.

		"Packages"
		spec package: 'SmallMuse' with:  [ spec requires: #('ZincHTTPComponents') ] ]
	

]

{ #category : #accessing }
BaselineOfSmallMuse >> projectClass [
	^ MetacelloCypressBaselineProject
]
