"
I represent a one-way portal between rooms.

A portal has a 'from' field holding a room id, and a 'to' field holding another room id, and a direction. The canonical directions are
	n (north),      s (south),
	e (east),       w (west),
	u (up),         d (down),
	ne (northeast), sw (southwest),
	nw (northwest), se (southeast)
The pairs are opposites - normally when you create one portal (say, north from room 1 to room 2), its opposite is also created (south from room 2 to room 1), but you can create a single portal without its opposite. This might be useful to build puzzles or traps.

Also, you can use any string as the direction, you are not limited to the compass/up/down directions.
"
Class {
	#name : #SMPortal,
	#superclass : #Object,
	#instVars : [
		'from',
		'to',
		'direction'
	],
	#category : #smallMuse
}

{ #category : #accessing }
SMPortal >> direction [
	^ direction
]

{ #category : #accessing }
SMPortal >> direction: anObject [
	direction := anObject
]

{ #category : #accessing }
SMPortal >> directionName [
	direction = 'u' ifTrue: [ ^ 'Up (u)' ].
	direction = 'd' ifTrue: [ ^ 'Down (d)' ].
	direction = 'n' ifTrue: [ ^ 'North (n)' ].
	direction = 's' ifTrue: [ ^ 'South (s)' ].
	direction = 'e' ifTrue: [ ^ 'East (e)' ].
	direction = 'w' ifTrue: [ ^ 'West (w)' ].
	direction = 'ne' ifTrue: [ ^ 'Northeast (ne)' ].
	direction = 'nw' ifTrue: [ ^ 'Northwest (nw)' ].
	direction = 'se' ifTrue: [ ^ 'Southeast (se)' ].
	direction = 'sw' ifTrue: [ ^ 'Southwest (sw)' ].
	^ direction capitalized
]

{ #category : #accessing }
SMPortal >> from: aRoom to: anotherRoom direction: aString [
	from := aRoom id.
	to := anotherRoom id.
	direction := aString.
	aRoom addExit: self.
]

{ #category : #accessing }
SMPortal >> to [
	^ to
]
