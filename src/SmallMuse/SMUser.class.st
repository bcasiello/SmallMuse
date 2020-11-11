"
I represent a SmallMuse user.

At the moment, I'm a pretty dumb object, mainly providing a bunch of accessors to my instance variables.
This may (well, let's say 'is likely to') change.
"
Class {
	#name : #SMUser,
	#superclass : #Object,
	#instVars : [
		'id',
		'email',
		'nick',
		'hashedPassword',
		'salt',
		'lastLogin',
		'lastAccess',
		'privilege',
		'room'
	],
	#category : #smallMuse
}

{ #category : #utilities }
SMUser class >> hash: password with: salt [
	^ SHA256 new hashStream: (ReadStream on: password , salt)
]

{ #category : #accessing }
SMUser >> avatar [
	^ 'https://www.gravatar.com/avatar/', (ZnDigestAuthenticator md5Hash: email) , '?s=40&d=identicon'
]

{ #category : #accessing }
SMUser >> email [
	^ email
]

{ #category : #accessing }
SMUser >> hashedPassword [
	^ hashedPassword
]

{ #category : #accessing }
SMUser >> id [
	^ id
]

{ #category : #accessing }
SMUser >> id: newId nick: newNick email: newEmail password: newPassword privilege: newPrivilege [
	id := newId.
	nick := newNick.
	email := newEmail.
	salt := ZnWebSocketUtils randomByteArrayOfSize: 32.
	hashedPassword := self class hash: newPassword with: salt.
	self privilege: newPrivilege

]

{ #category : #initialization }
SMUser >> initialize [
	privilege := #guest
]

{ #category : #testing }
SMUser >> isAllowedToPerform: selector [ 
	^ self privilege level >= (SMCommands privilegeOf: selector) level
]

{ #category : #accessing }
SMUser >> lastAccess [
	^ lastAccess
]

{ #category : #accessing }
SMUser >> lastAccess: time [
	lastAccess := time
]

{ #category : #accessing }
SMUser >> lastLogin [
	^ lastLogin
]

{ #category : #accessing }
SMUser >> lastLogin: anObject [
	lastLogin := anObject
]

{ #category : #accessing }
SMUser >> nick [
	^ nick
]

{ #category : #accessing }
SMUser >> privilege [
	^ SMPrivilege privileges at: privilege
]

{ #category : #accessing }
SMUser >> privilege: aSmallMusePrivilege [
	privilege := aSmallMusePrivilege name
]

{ #category : #accessing }
SMUser >> privilegeOf: user [
	^ user privilege
]

{ #category : #accessing }
SMUser >> room [
	^ room
]

{ #category : #accessing }
SMUser >> room: anObject [
	room := anObject
]

{ #category : #accessing }
SMUser >> salt [
	^ salt
]
