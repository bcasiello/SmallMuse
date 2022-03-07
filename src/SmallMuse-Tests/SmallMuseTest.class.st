Class {
	#name : #SmallMuseTest,
	#superclass : #TestCase,
	#instVars : [
		'muse'
	],
	#category : #'SmallMuse-Tests'
}

{ #category : #running }
SmallMuseTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
"	muse := SMWorldMock new.
	muse initWorld.
"
]

{ #category : #tests }
SmallMuseTest >> testSMCommands [
	| owner guest |
	muse := SMWorldMock new.
	muse startWorld: 'TestMuse' at: 'testmuse' on: 4242.
	muse gravatars: false.
	owner := muse users at: 0.
	guest := muse users at: 1.
	muse loggedInUsers at: 0 put: owner.
	muse loggedInUsers at: 1 put: guest.
	muse commandParser perform: 'hello' by: owner on: 0.
	self
		assert: SMWebSocketMock lastMessageSent
		equals:
			'<div class="row"><div class="text"><span class="nick">Owner: </span><span class="message">hello</span></div></div>'
]

{ #category : #tests }
SmallMuseTest >> testSMCounter [
	| counter |
	counter := SMCounter new.
	self assert: counter next equals: 0.
	self assert: counter next equals: 1.
	self assert: counter next equals: 2.
	self assert: counter next equals: 3.
	1 to: 100 do: [ :ignore | counter next ].
	self assert: counter next equals: 104.
]

{ #category : #tests }
SmallMuseTest >> testSMPortal [
	| room1 room2 portal |
	room1 := SMRoom new id: 1 name: 'test1' owner: 0.
	room2 := SMRoom new id: 2 name: 'test2' owner: 0.
	portal := SMPortal new from: room1 to: room2 direction: 'n'.
	self assert: portal directionName equals: 'North (n)'.
	self assert: portal to equals: room2 id.
	portal direction: 's'.
	self assert: portal directionName equals: 'South (s)'.
	portal direction: 'u'.
	self assert: portal directionName equals: 'Up (u)'.
	portal direction: 'd'.
	self assert: portal directionName equals: 'Down (d)'.
	portal direction: 'south-by-southwest'.
	self assert: portal directionName equals: 'South-by-southwest'.
]

{ #category : #tests }
SmallMuseTest >> testSMPrivilege [
	self assert: SMPrivilege guest     < SMPrivilege user.
	self assert: SMPrivilege user      < SMPrivilege builder.
	self assert: SMPrivilege builder   < SMPrivilege coder.
	self assert: SMPrivilege coder     < SMPrivilege architect.
	self assert: SMPrivilege architect < SMPrivilege owner
]

{ #category : #tests }
SmallMuseTest >> testSMRoom [
	| room1 room2 room3 |
	room1 := SMRoom new id: 1 name: 'test1' owner: 0.
	room2 := SMRoom new id: 2 name: 'test2' owner: 0.
	room3 := SMRoom new id: 3 name: 'test3' owner: 0.
	self assert: room1 exitsAsString equals: ''.
	SMPortal new from: room1 to: room2 direction: 'n'.
	self assert: room1 exitsAsString equals: 'Exits: North (n)'.
	SMPortal new from: room1 to: room3 direction: 'widdershins'.
	self assert: room1 exitsAsString equals: 'Exits: North (n), Widdershins'.
	SMPortal new from: room1 to: room3 direction: 'across'.
	self assert: room1 exitsAsString equals: 'Exits: Across, North (n), Widdershins'.

]

{ #category : #tests }
SmallMuseTest >> testSMUser [
	| user1 |
	user1 := SMUser new id: 1  nick: 'user1' email: 'user1@example.com' password: 'secret' privilege: SMPrivilege guest.
	self deny: (user1 isAllowedToPerform: #say:on:).
	self assert: (user1 isAllowedToPerform: #login:on:).
	user1 privilege: SMPrivilege user.
	self assert: (user1 isAllowedToPerform: #say:on:).
	self assert: (user1 isAllowedToPerform: #login:on:).

]

{ #category : #tests }
SmallMuseTest >> testSMWebSocketHandler [
	muse := SMWorldMock new.
	muse startWorld: 'TestMuse' at: 'testmuse' on: 4242.
	muse gravatars: false.
	muse loginUser: (muse users at: 0) on: 0.
	muse print: 'test' from: (muse users at: 0).
	self assert: muse socketHandler class lastMessageSent equals: '<div class="row"><div class="text"><span class="nick">Owner: </span><span class="message">test</span></div></div>'.
	muse pose: '''s nose is cold.' from: (muse users at: 0).	
	self assert: muse socketHandler class lastMessageSent equals: '<div class="row"><div class="text"><span class="nick">Owner''s nose is cold.</span></div></div>'.

]

{ #category : #tests }
SmallMuseTest >> testSMWorld [
	muse := SMWorldMock new.
	muse startWorld: 'TestMuse' at: 'testmuse' on: 4242.
	muse gravatars: false.
	muse move: (muse users at: 0) from: 1 to: 2 on: 0.
	self assert: SMWebSocketMock lastMessageSent equals: '<span class="info">Exits: North (n)</span><br />'.
	

]
