"
I represent a SmallMuse room.
"
Class {
	#name : #SMRoom,
	#superclass : #Object,
	#instVars : [
		'id',
		'name',
		'owner',
		'longName',
		'description',
		'exits',
		'contents',
		'permissions'
	],
	#category : #SmallMuse
}

{ #category : #utilities }
SMRoom class >> hash: password with: salt [
	^ SHA256 new hashStream: (ReadStream on: password , salt)
]

{ #category : #adding }
SMRoom >> addExit: exit [
	exits at: exit direction put: exit
]

{ #category : #accessing }
SMRoom >> contentsAsString [
	String streamContents: [ :out | 
		contents ifNotEmpty: [ out << 'contents: ' ].
		contents do: [ :each | 
			out << 'object'.
			out << ' ' ] ]
]

{ #category : #accessing }
SMRoom >> description [
	^ description
]

{ #category : #accessing }
SMRoom >> description: anObject [
	description := anObject
]

{ #category : #accessing }
SMRoom >> exits [
	^ exits
]

{ #category : #accessing }
SMRoom >> exits: anObject [
	exits := anObject
]

{ #category : #accessing }
SMRoom >> exitsAsString [
	| separator |
	^ String streamContents: [ :out | 
		  exits ifNotEmpty: [ out << 'Exits:' ].
		  separator := ' '.
		  exits do: [ :each | 
			  out << separator.
			  separator := ', '.
			  out << each directionName ] ]
]

{ #category : #accessing }
SMRoom >> id [
	^ id
]

{ #category : #accessing }
SMRoom >> id: newId name: newName owner: newOwner [
	id := newId.
	name := newName.
	longName := newName.
	description := newName.
	owner := newOwner.
	exits := Dictionary new.
	contents := Set new.
	permissions := Set new.

]

{ #category : #accessing }
SMRoom >> longName [
	^ longName
]

{ #category : #accessing }
SMRoom >> longName: anObject [
	longName := anObject
]

{ #category : #accessing }
SMRoom >> name [
	^ name
]

{ #category : #accessing }
SMRoom >> name: anObject [
	name := anObject
]

{ #category : #accessing }
SMRoom >> owner [
	^ owner
]

{ #category : #accessing }
SMRoom >> owner: anObject [
	owner := anObject
]
