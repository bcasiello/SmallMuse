"
I represent user commands.

I am responsible for parsing commands, checking privilege, and executing commands. I often use helper functions in the SmallMuse class to actually perform the actions.
Specifically, I neven talk to the socket interface myself, I always go through SmallMuse helpers.

All command methods are of the form <commandname>:on:
The first argument is the arguments sent by the user, if any, and the second is the user's socket.
The command response goes back to the user, but the command may cause messages to other users' sockets. For example, if the user 'says' something, the message they say is sent to all the sockets associated with other users in the same room.

Some examples:
	If the user types
		/help builders
	then the message
		help: 'builders' on: <socket>
	is sent, which ends up sending the file builders.html back to the user's socket.
	If a user (whose nick is Gandalf) types
		/pose ate the plums that were in your icebox.
	then the message
		pose: 'ate the plums that were in your icebox.' on: <socket>
	is sent, and every user in the same room as Gandalf (including Gandalf himself) sees the message
		Gandalf ate the plums that were in your icebox.

"
Class {
	#name : #SMCommands,
	#superclass : #Object,
	#instVars : [
		'muse'
	],
	#category : #smallMuse
}

{ #category : #constants }
SMCommands class >> architectCommands [
	^ #(  )
]

{ #category : #constants }
SMCommands class >> builderCommands [
	^ #( #dig:on:)
]

{ #category : #constants }
SMCommands class >> coderCommands [
	^ #(  )
]

{ #category : #constants }
SMCommands class >> guestCommands [
	^ #( #help:on: #login:on: #register:on: )
]

{ #category : #constants }
SMCommands class >> ownerCommands [
	^ #(  )
]

{ #category : #accessing }
SMCommands class >> privilegeOf: selector [
	(self guestCommands     includes: selector) ifTrue: [ ^ SMPrivilege guest ].
	(self userCommands      includes: selector) ifTrue: [ ^ SMPrivilege user ].
	(self builderCommands   includes: selector) ifTrue: [ ^ SMPrivilege builder ].
	(self coderCommands     includes: selector) ifTrue: [ ^ SMPrivilege coder ].
	(self architectCommands includes: selector) ifTrue: [ ^ SMPrivilege architect ].
	(self ownerCommands     includes: selector) ifTrue: [ ^ SMPrivilege owner ].

	"Any command we don't recognize gets owner privilege to prevent misuse."
	^ SMPrivilege owner
]

{ #category : #parsing }
SMCommands class >> tokenize: aString [
	| result |
	"Tokenizes a string by whitespace (spaces and tabs), with quoted strings returned as single tokens.
	
	tokenize: 'a b ""c d"" e ''f g'' h' returns six tokens, not eight.
	
	The quotes are not part of the token, so the six tokens are
		a
		b
		c d
		e
		f g
		h
		
	Multiple adjacent whitespace characters cause findTokens to produce empty tokens,
	so we filter them out with the select:. We could filter adjacent separators out of the
	string first, but that might remove significant characters in quoted strings.
	
	Note: the results of tokenize: are non-reversible.
	- Quotes are removed.
	- Adjacent separators are removed.
	So tokenize: is inappropriate where either of those would be a problem.
		"
	result := (aString findTokens: Character separators escapedBy: '''"') 
		          select: [ :each | each isNotEmpty ].
	SMWorld logMessage: aString, ' was tokenized as ', result printString.
	^ result
]

{ #category : #constants }
SMCommands class >> userCommands [
	^ #( go:on: #logout:on: #pose:on: #say:on: #semipose:on: #who:on: )
]

{ #category : #constants }
SMCommands >> commandPrefix [
	^ $/
]

{ #category : #commands }
SMCommands >> go: arguments on: socket [
	| words direction |
	words := self class tokenize: arguments.
	words size < 1 ifTrue: [ 
		muse print: 'If you want to go somewhere, you need to tell me which direction!' on: socket.
		^ self ].
	direction := (words at: 1) asLowercase.
	direction = 'up' ifTrue: [direction := 'u'].
	direction = 'down' ifTrue: [direction := 'd'].
	direction = 'north' ifTrue: [direction := 'n'].
	direction = 'south' ifTrue: [direction := 's'].
	direction = 'east' ifTrue: [direction := 'e'].
	direction = 'west' ifTrue: [direction := 'w'].
	direction = 'northeast' ifTrue: [direction := 'ne'].
	direction = 'northwest' ifTrue: [direction := 'nw'].
	direction = 'southeast' ifTrue: [direction := 'se'].
	direction = 'southwest' ifTrue: [direction := 'sw'].
	muse move: (muse loggedInUsers at: socket) direction: direction on: socket.

]

{ #category : #commands }
SMCommands >> help: arguments on: socket [
	| words file |
	arguments ifEmpty: [ 
		muse sendPage: 'help/help.html' on: socket.
		^ self ].
	words := self class tokenize: arguments.
	words ifEmpty: [ 
		muse sendPage: 'help/help.html' on: socket.
		^ self ].
	file := words at: 1.
	file first = muse commandPrefix ifTrue: [ file := file allButFirst ].
	(muse homeDirectory / 'help' / (file , '.html')) exists ifTrue: [ 
		muse sendPage: 'help/', file, '.html' on: socket.
		^ self ].
	muse
		print: 'No help available for ''' , (words at: 1) , ''''
		on: socket
]

{ #category : #commands }
SMCommands >> login: arguments on: socket [
	| words nick password hashedPassword salt user |
	words := self class tokenize: arguments.
	words size ~= 2 ifTrue: [ 
		^ muse sendPage: 'loginError.html' on: socket ].
	nick := words at: 1.
	password := words at: 2.
	user := muse users detect: [ :aUser | aUser nick = nick ] ifNone: [^ muse sendPage: 'loginError.html' on: socket].
	salt := user salt.
	hashedPassword := SMUser hash: password with: salt.
	hashedPassword = user hashedPassword ifFalse: [ 
		^ muse sendPage: 'loginError.html' on: socket ].
	self logout: '' on: socket. "Logout current user"
	muse loginUser: user on: socket
]

{ #category : #commands }
SMCommands >> logout: ignored on: socket [
	| user |
	user := muse loggedInUsers at: socket ifAbsent: [ ^ self ].
	muse logoutUser: user on: socket
]

{ #category : #accessing }
SMCommands >> muse [
	^ muse
]

{ #category : #accessing }
SMCommands >> muse: anObject [
	muse := anObject
]

{ #category : #parsing }
SMCommands >> perform: message by: user on: socket [
	"Performs a command from 'message' on behalf of 'user' attached to 'socket'."

	| firstSpace commandLine command arguments |
	message ifEmpty: [ ^ self ].
	"If the message doesn't start with the command prefix, it's a 'say'."
	message first = self commandPrefix ifFalse: [ 
		^ self perform: 'say' with: message by: user on: socket ].
	commandLine := message allButFirst.
	firstSpace := commandLine findString: ' '.
	firstSpace = 0
		ifTrue: [
			"No spaces, the entire string is the command."
			command := commandLine.
			arguments := '' ]
		ifFalse: [ 
			command := commandLine copyFrom: 1 to: firstSpace - 1.
			arguments := commandLine
				             copyFrom: firstSpace + 1
				             to: commandLine size ].
	"Shortcuts"
	command = ':' ifTrue: [ command := 'pose' ].
	command = ';' ifTrue: [ command := 'semipose' ].
	^ self perform: command with: arguments trimLeft by: user on: socket
]

{ #category : #parsing }
SMCommands >> perform: command with: arguments by: user on: socket [
	"Performs 'command' with 'arguments' on behalf of 'user' attached to 'socket'."

	| actualCommand selector |
	actualCommand := command ifEmpty: [ 'say'].
	selector := (actualCommand , ':on:') asSymbol.
	(user isAllowedToPerform: selector) ifFalse: [ 
		muse
			print: 'You don''t have permission to ''' , command , ' ', arguments, ''''
			on: socket.
		^ self ].
	(self class canPerform: selector) ifFalse: [ 
		muse print: 'I don''t know how to ''' , command , ' ', arguments, '''' on: socket.
		^ self ].
	self perform: selector with: arguments with: socket
]

{ #category : #commands }
SMCommands >> pose: arguments on: socket [
	muse pose: ' ', arguments from: (muse loggedInUsers at: socket).

]

{ #category : #commands }
SMCommands >> register: arguments on: socket [
	"User command to register a new user. The user is automatically logged in.

	If the socket is already attached to a logged-in user, that user is logged out.
	
	Expects words to contain nick, email-address, and password.
	
	Note: multiple nicks with the same email address are explicitly allowed."

	| words nick email password user |
	words := self class tokenize: arguments.
	words size ~= 3 ifTrue: [ 
		muse sendPage: 'registrationError.html' on: socket.
		^ nil ].
	nick := words at: 1.
	password := words at: 2.
	email := words at: 3.
	(muse users includesKey: nick) ifTrue: [ 
		muse sendPage: 'nickInUse.html' on: socket.
		^ nil ].
	user := SMUser new
		        id: muse counter next
		        nick: nick
		        email: email
		        password: password
					privilege: SMPrivilege user.
	muse users at: nick put: user.
	self logout: '' on: socket. "Logout current user"
	muse loginUser: user on: socket.
	muse saveWorld
]

{ #category : #commands }
SMCommands >> say: arguments on: socket [
	muse print: ' ', arguments from: (muse loggedInUsers at: socket).

]

{ #category : #commands }
SMCommands >> semipose: arguments on: socket [
	muse pose: arguments from: (muse loggedInUsers at: socket).

]

{ #category : #commands }
SMCommands >> who: ignored on: socket [
	muse printWho: ignored on: socket

]
