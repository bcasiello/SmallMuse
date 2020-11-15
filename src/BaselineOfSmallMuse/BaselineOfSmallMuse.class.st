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
		"Dependencies"
		self zincHTTPComponents: spec.

		"Packages"
		spec package: 'SmallMuse' with:  [ spec requires: #('ZincHTTPComponents') ] ]
	

]

{ #category : #actions }
BaselineOfSmallMuse >> preload: loader package: packageSpec [
	Gofer new
		smalltalkhubUser: 'SvenVanCaekenberghe'
			project: 'ZincHTTPComponents';
		package: 'ConfigurationOfZincHTTPComponents';
		load.
	(Smalltalk globals at: #ConfigurationOfZincHTTPComponents) project
		latestVersion load: 'WebSocket'
]

{ #category : #accessing }
BaselineOfSmallMuse >> projectClass [
	^ MetacelloCypressBaselineProject
]

{ #category : #'as yet unclassified' }
BaselineOfSmallMuse >> zincHTTPComponents: spec [
	spec
		project: 'ZincHTTPComponents'
		with: [ spec
				className: #ConfigurationOfZincHTTPComponents;
				versionString: #stable;
				repository:
					'http://smalltalkhub.com/mc/SvenVanCaekenberghe/ZincHTTPComponents/main/']
]
