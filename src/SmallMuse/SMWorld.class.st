"
A small MUSE in Smalltalk.

SmallMuse is web-based (it uses websockets) so only a browser is needed to play.
(If you're having trouble, check https://caniuse.com/?search=websockets to see
if your particular browser and version has websockets support.)

All users are allowed to build; the system might set limits on how much. This may
be a total number of items, or number of items per unit time.

By default, users (except admins, who are all-powerful) are not allowed to modify
anything created by another user. A user can set permissions allowing, for
example, any other user to dig an exit from the player's room to another room,
and to write to a 'guest book' object, but only allow certain other players to
add new items to a room.

Users are not allowed to modify any attributes of another user's character.

Admins, however, are allowed to modify other users' objects or character. They
should of course use this privilege judiciously; especially, in the case of other
users' characters, they should modify them only to solve a serious problem.

If the serious problem is due to a bug in the code, PLEASE report it to the
project maintainers.

A little bit more about user levels:

Owner	Allowed to modify any object in the system, including characters.
Admin	Allowed to modify any object owned by themselves, or any non-admin users.
User	Allowed to modify any object they own.
	
		Every object in the system has exactly one owner.
		Users own their own characters.
		Users own any object they create, unless they transfer ownership to
		another user.
		Users own any object that has been tranferred to them by another user.

Instance variables:
	users is a dictionary of known users of the Muse, using their nick as the key.
	loggedInUsers is a dictionary of currently logged-in users, with their socket as the key.
	templates is a dictionary of template files, whose key is their base name.
			Valid files are .html, .css, and .js.
			for example, templates/styles.css has key 'styles' and value 'styles.css'.
			they are used in Mustache templates,  {{{ styles }}} is replaced with the contents
			of styles.css.
			Note that this means files must have different base names. You can't have a
			css file named 'styles.css' and a Javascript file named 'styles.js'.
			If this turns out to be problematic, we can add the extension into the keys.
			
	Protocols
		command - user-executable command - they are all named <command>:on:
		and are invoked by the user as /command arguments
		the command: specifies the arguments and the on: specifies the socket
		So the user command
			/login joe joes-password
		causes the message
			login: OrderedCollection('joe', 'joes-password') on: joes-socket
		to be sent to the SmallMuse instance
          11111111112222222222333333333344444444445555555555666666666677777777778
012345678901234567890123456789012345678901234567890123456789012345678901234567890

"
Class {
	#name : #SMWorld,
	#superclass : #Object,
	#instVars : [
		'mutex',
		'users',
		'rooms',
		'loggedInUsers',
		'templates',
		'homeDirectory',
		'socketHandler',
		'counter',
		'gravatars',
		'commandParser'
	],
	#category : #SmallMuse
}

{ #category : #printing }
SMWorld class >> printUTCDateAndTime: aDateTime on: aStream [
	| utcDateTime |
	"Print as per RFC 5424.
	Based on BasicDatePrinter.
	"

	utcDateTime := aDateTime asUTC.
	BasicDatePrinter default printYMD: utcDateTime withLeadingSpace: false on: aStream.
	aStream nextPut: $T.
	BasicDatePrinter default printHMS: utcDateTime separatedBy: $: on: aStream.
	aStream nextPut: $..
	utcDateTime nanoSecond / 1000000 printOn: aStream base: 10 length: 3 padded: true.
	aStream nextPut: $Z.

]

{ #category : #handlers }
SMWorld class >> shutdownAll [
	3 timesRepeat: [ 
		ZnServer managedServers do: [ :each | ZnServer unregister: each ].
		ZnServer managedServers ifNotEmpty: [ 
			(ZnServer managedServers size asString , ' instances left.') record ] ].
	ZnServer managedServers ifEmpty: [ 
		'all instances shut down' record ]
]

{ #category : #handlers }
SMWorld >> compactDuration: duration [
	^ String streamContents: [ :out | 
		self printCompactDuration: duration on: out ]
]

{ #category : #accessing }
SMWorld >> gravatars [
	^ gravatars
]

{ #category : #accessing }
SMWorld >> gravatars: anObject [
	gravatars := anObject
]

{ #category : #accessing }
SMWorld >> homeDirectory [
	^ homeDirectory
]

{ #category : #initialization }
SMWorld >> initWorld [
	"Initialize the world with the owner, a guest, and two connected rooms."

	| owner firstRoom secondRoom |
	self gravatars: true.
	owner := self
		         newUserWithNick: 'Owner'
		         email: 'bcasiello@yahoo.com'
		         password: 'secret'
		         privilege: SMPrivilege owner.
	self
		newUserWithNick: 'Guest'
		email: ''
		password: ''
		privilege: SMPrivilege guest.
	firstRoom := self newRoomWithName: 'Lobby' owner: owner.
	firstRoom longName: 'the Lobby'.
	firstRoom description:
		'You are in a large room with ivory colored walls, many standing plants, and four columns surrounding a circular area with comfortable chairs arranged around a glass table. There is a gold chandelier above the table.'.
	secondRoom := self newRoomWithName: 'Backroom' owner: owner.
	secondRoom longName: 'the Backroom'.
	secondRoom description:
		'You are in a small, rectanguar room with a large table surrounded by several folding chairs. The table is littered with papers, coffee cups, napkins, and an empty donut box.'.
	self
		newDoorFrom: firstRoom
		to: secondRoom
		direction: 'n'
		oppositeDirection: 's'
]

{ #category : #initialization }
SMWorld >> initialize [

	super initialize.
	mutex := Mutex new.
	users := Dictionary new.
	rooms := Dictionary new.
	commandParser := SMCommands new muse: self.
	gravatars := false.
	
]

{ #category : #handlers }
SMWorld >> loadWorld [
	| world in |
	world := 	homeDirectory / 'world.ston'.
	world exists ifFalse: [
		'World file does not exist. Creating a new world!' record.
		^ self initWorld].
	in := world readStream.
	counter := STON fromStream: in.
	gravatars := STON fromStream: in.
	users := STON fromStream: in.
	rooms := STON fromStream: in.
	in close
	
]

{ #category : #accessing }
SMWorld >> loggedInUsers [
	^ loggedInUsers
]

{ #category : #accessing }
SMWorld >> loggedInUsers: anObject [
	loggedInUsers := anObject
]

{ #category : #handlers }
SMWorld >> loginUser: user on: socket [
	loggedInUsers detect: [ :aUser | aUser = user ] ifFound: [ 
		self print: 'You''re already logged in somewhere else!' on: socket.
		^ self ].
	socketHandler pose:  ' has logged in.' from: user.
	user lastLogin: DateAndTime now.
	user lastAccess: user lastLogin copy.
	user room ifNil: [ user room: 2 ].
	loggedInUsers at: socket put: user.
	self saveWorld.
	self user: user enterRoom: user room on: socket.
	socketHandler printWho.
	socketHandler printRooms
]

{ #category : #handlers }
SMWorld >> logoff: socket [
	loggedInUsers removeKey: socket ifAbsent: []
]

{ #category : #handlers }
SMWorld >> logoutUser: user on: socket [
	socketHandler pose: ' has logged out.' from: user.
	loggedInUsers removeKey: socket.
	socketHandler printWho.
	socketHandler printRooms
]

{ #category : #handlers }
SMWorld >> makeRoom: name direction: direction reverse: reverse longname: longname description: description on: socket [
	| user currentRoom room |
	user := loggedInUsers at: socket.
	currentRoom := rooms at: user room.
	room := self newRoomWithName: name owner: user.
	room longName: longname.
	room description: description.
	self newDoorFrom: currentRoom to: room direction: direction oppositeDirection: reverse.
	self move: user from: currentRoom id to: room id on: socket.
	self saveWorld
]

{ #category : #handlers }
SMWorld >> move: user direction: direction on: socket [
	| newRoom exit |
	exit := (rooms at: user room) exits at: direction ifAbsent: [ self print: 'You can''t go that way.' on: socket. ^ self].
	newRoom := rooms at: exit to.
	exit ifNil: [ self print: 'There''s nothing that way.' on: socket. ^ self].
	self move: user from: user room to: newRoom id on: socket.

]

{ #category : #handlers }
SMWorld >> move: user from: oldRoom to: newRoom on: socket [
	self user: user exitRoom: oldRoom on: socket.
	self user: user enterRoom: newRoom on: socket.
	socketHandler printWho

]

{ #category : #'instance creation' }
SMWorld >> newDoorFrom: firstRoom to: secondRoom direction: aString oppositeDirection: anotherString [
	"A 'door' is simply a pair of portals with opposite rooms."
	| door1 door2 |
	
	door1 := SMPortal new from: firstRoom to: secondRoom direction: aString.
	door2 := SMPortal new from: secondRoom to: firstRoom direction: anotherString.
	firstRoom addExit: door1.
	secondRoom addExit: door2.
	self saveWorld.
	^ self
	
]

{ #category : #'instance creation' }
SMWorld >> newPortalFrom: firstRoom to: secondRoom direction: aString [
	| door |
	
	door := SMPortal new from: firstRoom to: secondRoom direction: aString.
	firstRoom addExit: door.
	self saveWorld.
	^ self
	
]

{ #category : #'instance creation' }
SMWorld >> newRoomWithName: name owner: owner [
	| room |
	room := SMRoom new id: counter next name: name owner: owner id.
	rooms at: room id put: room.
	self saveWorld.
	socketHandler printRooms.
	^ room
	
]

{ #category : #'instance creation' }
SMWorld >> newUserWithNick: nick email: email password: password privilege: privilege [
	| user |
	user := SMUser new.
	user id: counter next nick: nick email: email password: password privilege: privilege.
	users at: user id put: user.
	self saveWorld.
	^ user.
]

{ #category : #accessing }
SMWorld >> nextCounter [
	mutex critical: [ ^ counter next ]
]

{ #category : #printing }
SMWorld >> pose: message from: user [
	socketHandler pose: message from: user
]

{ #category : #printing }
SMWorld >> print: message from: user [
	socketHandler print: message from: user
]

{ #category : #running }
SMWorld >> print: message on: socket [
	socketHandler print: message on: socket
]

{ #category : #printing }
SMWorld >> print: message with: class on: socket [
	socketHandler print: message with: class on: socket
]

{ #category : #handlers }
SMWorld >> printCompactDuration: duration on: stream [
	| outputWritten count |
	outputWritten := false.
	duration negative 
		ifTrue: [ 
			stream << '- '. 
			^ self printCompactDuration: duration abs on: stream ].
	#( (days 'd') 
		(hours 'h') 
		(minutes 'm') 
		(seconds 's')) do: [ :each |
		count := (duration perform: each first) truncated.
		count > 0 
			ifTrue: [
				outputWritten ifTrue: [ stream space ].				
				count printWithCommasOn: stream.
				stream << (each second ).
				outputWritten := true ] ].
	outputWritten ifFalse: [ stream << '0 s' ]
]

{ #category : #printing }
SMWorld >> printWho: ignored on: socket [ 
	socketHandler printWho: ignored on: socket
]

{ #category : #handlers }
SMWorld >> processMessage: message on: socket [
	| user |
	user := self loggedInUsers at: socket ifAbsent: [ users at: 1 ].
	user lastAccess: DateAndTime now.
	commandParser perform: message by: user on: socket

]

{ #category : #accessing }
SMWorld >> rooms [
	^ rooms
]

{ #category : #handlers }
SMWorld >> saveWorld [
	| out file |
	file := homeDirectory / 'world.ston'.
	file exists ifTrue: [ file delete ].
	out := file writeStream.
	STON put: counter onStreamPretty: out.
	STON put: gravatars onStreamPretty: out.
	STON put: users onStreamPretty: out.
	STON put: rooms onStreamPretty: out.
	out close
]

{ #category : #accessing }
SMWorld >> sendPage: page on: socket [
	socketHandler print: (self templatizedPage: homeDirectory / page) on: socket
]

{ #category : #handlers }
SMWorld >> setDelegates [
	socketHandler := SMWebSocketHandler new muse: self.
	ZnServer default delegate
		map: 'smallmuse' to: [ :request | 
			ZnResponse ok: (ZnEntity html:
							 (self templatizedPage: homeDirectory / 'smallmuse.html')) ];
		map: 'ws-chatroom'
		to: (ZnWebSocketDelegate map: 'ws-chatroom' to: socketHandler)
]

{ #category : #initialization }
SMWorld >> startLogger [
	TinyLogger default removeAllLoggers.
	TinyLogger default addFileLoggerNamed: homeDirectory / 'debug.log'.
	TinyLogger default timestampFormatBlock: [ :aStream :timestamp | 
		self class printUTCDateAndTime: timestamp on: aStream ].
]

{ #category : #accessing }
SMWorld >> startWorld: name at: location on: port [

	counter := SMCounter new.
	homeDirectory := location asFileReference isAbsolute
		                 ifTrue: [ location asFileReference ]
		                 ifFalse: [ 
		                 FileLocator imageDirectory asFileReference
		                 / location ].
	
	self startLogger.
	'SmallMuse started' record.

	loggedInUsers := Dictionary new.
	socketHandler := SMWebSocketHandler new muse: self.
	[ self loadWorld ]
		on: Error
		do: [ :ex | 
					('ERROR - server not started - error reading world file: ', ex description) record.
			^ self ].
	ZnServer startDefaultOn: port.
	ZnServer default loggingOff.
	self setDelegates
]

{ #category : #handlers }
SMWorld >> stop [
	loggedInUsers := Dictionary new.
	ZnServer stopDefault
]

{ #category : #handlers }
SMWorld >> templatizedPage: page [
	"This reads the template directory anew for every call.
	 This is fine for development or perhaps with a small number of templates on
	 a lightly loaded system.
	 For production, we should only call this once, or on some sort of signal."


	self updateTemplates.
	^ (MustacheTemplate on: page contents) value: templates.

]

{ #category : #handlers }
SMWorld >> updateTemplates [
	| files extensions |
	templates := Dictionary new.
	extensions := Set with: 'html' with: 'css' with: 'js'.
	files := (homeDirectory / 'templates') allChildren select: [ :each | 
		         each isFile and: (extensions includes: each extension) ].
	files do: [ :each | templates at: each base put: each contents ]
]

{ #category : #handlers }
SMWorld >> user: user enterRoom: roomId on: socket [
	| room |
	user room: roomId.
	room := rooms at: roomId.
	self
		print: 'You have entered ' , room longName
		with: 'message'
		on: socket.
	(loggedInUsers select: [ :each | 
		 each room = roomId & (each id ~= user id) ]) keysDo: [ :each | 
		self print: user nick , ' has entered the room.' on: each ].
	self print: room description on: socket.
	room exits ifNotEmpty: [ self print: room exitsAsString on: socket ]
]

{ #category : #handlers }
SMWorld >> user: user exitRoom: roomId on: socket [
	(loggedInUsers select: [ :each | 
		 each room = roomId & (each id ~= user id) ]) keysDo: [ :each | 
		self print: user nick , ' has left the room.' on: each ].

]

{ #category : #accessing }
SMWorld >> users [
	^ users
]

{ #category : #accessing }
SMWorld >> users: anObject [
	users := anObject
]
