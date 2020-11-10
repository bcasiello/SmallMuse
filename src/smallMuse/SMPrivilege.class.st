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
		'name',
		'level'
	],
	#classVars : [
		'Privileges'
	],
	#category : #smallMuse
}

{ #category : #'instance creation' }
SMPrivilege class >> architect [
	^ self name: #architect level: 5
]

{ #category : #'instance creation' }
SMPrivilege class >> builder [
	^ self name: 'builder' level: 3
]

{ #category : #'instance creation' }
SMPrivilege class >> coder [
	^ self name: 'coder' level: 4
]

{ #category : #'instance creation' }
SMPrivilege class >> guest [
	^ self name: 'guest' level: 1
]

{ #category : #'instance creation' }
SMPrivilege class >> name: privilegeName level: privilegeLevel [
	^ self privileges at: privilegeName ifAbsentPut: [ self new name: privilegeName level: privilegeLevel ]
]

{ #category : #'instance creation' }
SMPrivilege class >> owner [
	^ self name: 'owner' level: 6
]

{ #category : #internal }
SMPrivilege class >> privileges [
	^ Privileges ifNil: [ Privileges := SmallDictionary new ]
]

{ #category : #'instance creation' }
SMPrivilege class >> user [
	^ self name: 'user' level: 2
]

{ #category : #accessing }
SMPrivilege >> level [
	^ level
]

{ #category : #accessing }
SMPrivilege >> name [
	^ name
]

{ #category : #accessing }
SMPrivilege >> name: newName level: newLevel [
	name := newName.
	level := newLevel
]
