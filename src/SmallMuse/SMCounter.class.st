"
I am a thread-safe counter.

nextCounter retrieves the next counter value
counter 	returns the current value
counter: sets the starting value

If you use counter: to set a lower value after you've used nextCounter, you can end up with duplicate values. 
"
Class {
	#name : #SMCounter,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #SmallMuse
}

{ #category : #initialization }
SMCounter >> initialize [
	super initialize.
	value := -1
]

{ #category : #initialization }
SMCounter >> next [
	^ value := value + 1
]
