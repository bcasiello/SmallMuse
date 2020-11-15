"
I represent SmallMuse privilege levels.

Users and commands have privilege levels. If the user's level is equal to or above the command's level, then the user is allowed to perform that command.

The levels, from lowest to highest are
	guest
	user
	builder
	coder
	architect
	owner

There is only one 'owner'-level user, which has access to anything in the system.

A user is at level 'guest' until they log in (registration automatically logs them in). The default level for logged-in users is 'user'. A user of level 'coder', 'architect', or 'owner' can raise another user's level to anything below their own level.
Coders can promote others to builder, architects can promote to builder or coder, and only the owner can promote to architect.
"
Class {
	#name : #SMPrivilege,
	#superclass : #Object,
	#instVars : [
		'level'
	],
	#classVars : [
		'privileges'
	],
	#category : #SmallMuse
}

{ #category : #'instance creation' }
SMPrivilege class >> architect [
	^ self new level: #architect
]

{ #category : #'instance creation' }
SMPrivilege class >> builder [
	^ self new level: #builder
]

{ #category : #'instance creation' }
SMPrivilege class >> coder [
	^ self new level: #coder
]

{ #category : #'instance creation' }
SMPrivilege class >> guest [
	^ self new level: #guest
]

{ #category : #'instance creation' }
SMPrivilege class >> owner [
	^ self new level: #owner
]

{ #category : #'instance creation' }
SMPrivilege class >> user [
	^ self new level: #user
]

{ #category : #comparing }
SMPrivilege >> < aLevel [
	^ self class = aLevel class and: [ self value < aLevel value ]
]

{ #category : #comparing }
SMPrivilege >> <= aLevel [
	^ self class = aLevel class and: [ self value <= aLevel value ]
]

{ #category : #comparing }
SMPrivilege >> = aLevel [
	^ self class = aLevel class and: [ self value = aLevel value ]
]

{ #category : #comparing }
SMPrivilege >> > aLevel [
	^ self class = aLevel class and: [ self value > aLevel value ]
]

{ #category : #comparing }
SMPrivilege >> >= aLevel [
	^ self class = aLevel class and: [ self value >= aLevel value ]

]

{ #category : #comparing }
SMPrivilege >> hash [
	^ self class hash bitXor: self level hash
]

{ #category : #accessing }
SMPrivilege >> level [
	^ level
]

{ #category : #accessing }
SMPrivilege >> level: aLevel [
	level := aLevel
]

{ #category : #evaluating }
SMPrivilege >> value [
	self level = #guest     ifTrue: [ ^ 1 ].
	self level = #user      ifTrue: [ ^ 2 ].
	self level = #builder   ifTrue: [ ^ 3 ].
	self level = #coder     ifTrue: [ ^ 4 ].
	self level = #architect ifTrue: [ ^ 5 ].
	self level = #owner     ifTrue: [ ^ 6 ]
]

{ #category : #comparing }
SMPrivilege >> ~= aLevel [
	^ self class ~= aLevel class or: [ self value ~= aLevel value ]
]
