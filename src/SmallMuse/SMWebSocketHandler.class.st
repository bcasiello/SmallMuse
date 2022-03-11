"
I handle a websocket connection for SmallMuse

I am responsible for the socket I/O and also for the formatting of output. For example, I wrap text in <span> elements tagged with classes to allow for color and other display characteristics. If a Telnet client class is written, it may send ANSI code sequences to provide for the same effect.

The value: method is called when a new socket connects. It sends the welcome message and loops, receiving a message from the socket and sends the SmallMuse instance's processMessage message.

print:on: writes an informational message to the given socket. Normally, this is to respond to a particular user, say, to let them know that a command wasn't understood.

print:with:on: is similar to print:on: but allows the user to specify a class of message, which determines the styling.
Currently these include
	'nick'    styled like the nickname of a 'say' message, or an entire 'pose' message.
	'info'    styled like an information message from the system.
	'message' styled like the message part of a 'say message.
For websockets, the style is plugged into the 'class' attribute of the HTML element surrounding the text, for Telnet sockets
(whenever those get supported) it will likely get translated into ANSI color code sequences.

printWho:on: write the 'who is on' list to the given socket. The output is tabular, so needs some careful formatting.

print:from: and pose:from: write the message to a colletion of sockets, from a particular user so they are formatted with a specific styling for the nick and pose, and a styling for the 'spoken' text.
They can optionally (for websockets) include a gravatar icon for the user.
(See https://www.gravatar.com/)

These methods all send messages to the class method send:to: to actually send the output to a collection of sockets and handle any errors.

"
Class {
	#name : #SMWebSocketHandler,
	#superclass : #ZnWebSocketChatroomHandler,
	#instVars : [
		'muse'
	],
	#category : #SmallMuse
}

{ #category : #running }
SMWebSocketHandler class >> send: message to: sockets [
	sockets do: [ :each | 
		[ each sendMessage: message ]
			on: NetworkError
			do: [ :exception | "We can ignore this (instead of #unregister:-ing the offender), 
					since the listener process (see #value:) will do the right thing" 
				each logGeneric:
					exception printString ] ]
]

{ #category : #accessing }
SMWebSocketHandler >> muse [
	^ muse
]

{ #category : #accessing }
SMWebSocketHandler >> muse: anObject [
	muse := anObject
]

{ #category : #accessing }
SMWebSocketHandler >> pose: message from: user [
	| output |
	output :=		'<div class="row">' ,
						(muse gravatars ifTrue: [ 
							'<div class="avatar"><img src="' , user avatar, '" /></div>' ] ifFalse: ['']),
						'<div class="text"><span class="nick">' , user nick, message, '</span>',
						'</div>',
					'</div>'.
	(muse loggedInUsers select: [ :each | 
		 each room = user room ]) keysDo: [ :each | 
		lock critical: [ self class send: output to: { each } ] ]
]

{ #category : #accessing }
SMWebSocketHandler >> print: message from: user [
	| output |
	output :=		'<div class="row">' ,
						(muse gravatars ifTrue: [ 
							'<div class="avatar"><img src="' , user avatar, '" /></div>' ] ifFalse: ['']),
						'<div class="text"><span class="nick">' , user nick, ': </span>',
							'<span class="message">' , message, '</span>',
						'</div>',
					'</div>'.
	(muse loggedInUsers select: [ :each | each room = user room ]) 
		keysDo: [ :each | 
		lock critical: [ self class send: output to: { each } ] ]
]

{ #category : #running }
SMWebSocketHandler >> print: message on: socket [
	self print: message with: 'info' on: socket

]

{ #category : #printing }
SMWebSocketHandler >> print: message with: class on: socket [
	| output |
	output := '<span class="', class, '">' , message , '</span><br />'.
	lock critical: [ self class send: output to: { socket } ]
]

{ #category : #printing }
SMWebSocketHandler >> printRooms [
	| output |
	output := String streamContents: [ :out | 
					out << '@rooms@'.
		          muse rooms do: [ :each | 
			          out << ('<li class"nick">{1}</li>' format: { 
					           (each name) })]].
	muse loggedInUsers keysDo: [ :each | 
		lock critical: [ self class send: output to: { each } ]]

]

{ #category : #printing }
SMWebSocketHandler >> printWho [
	| output |
	output := String streamContents: [ :out | 
		          out << '@who@'.
		          muse loggedInUsers do: [ :each | 
			          out << ('<li class"nick">{1} ({2})</li>' format: { 
					           each nick.
					           (muse rooms at: each room) name }) ] ].
	muse loggedInUsers keysDo: [ :each | 
		lock critical: [ self class send: output to: { each } ] ]
]

{ #category : #printing }
SMWebSocketHandler >> printWho: ignored on: socket [
	| output |
	output := String streamContents: [ :out | 
		          out << ('<span class="mono">{1} {2} {3} {4}' format: { 
				           ('Who' padRightTo: 16).
							  ('Where' padRightTo: 16).
				           ('On' padRightTo: 8).
				           'Idle' }).
		          out << String cr.
		          muse loggedInUsers do: [ :each | 
			          out << ('{1} {2} {3} {4}' format: { 
					           (each nick padRightTo: 16).
								  ((muse rooms at: each room) name padRightTo: 16).
					           ((muse compactDuration:
						             DateAndTime now - each lastLogin) padRightTo: 8).
					           ((muse compactDuration:
						             DateAndTime now - each lastAccess) padRightTo: 8) }).
			          out << String cr ].
		          out << '</span>' ].
	lock critical: [ self class send: output to: { socket } ]
]

{ #category : #accessing }
SMWebSocketHandler >> value: webSocket [
	[ 
	self register: webSocket.
	muse sendPage: 'welcome.html' on: webSocket.
	webSocket runWith: [ :message | 
		('Received message: ' , message printString) record.
		muse processMessage: message on: webSocket ] ]
		on: NetworkError
		do: [ 
			'Network error, cleaning up' record.
			muse logoff: webSocket.
			self unregister: webSocket ]
]
