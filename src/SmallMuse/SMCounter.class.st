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
		'lock',
		'value'
	],
	#category : #smallMuse
}

{ #category : #initialization }
SMCounter >> initialize [
	super initialize.
	lock := Mutex new.
	value := -1.

]

{ #category : #initialization }
SMCounter >> next [
	lock critical: [ 
		value := value + 1.
		^ value ]
]
