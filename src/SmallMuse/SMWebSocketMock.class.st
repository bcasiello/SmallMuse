"
Mock object for SmWebSocketHandler
- class method send:to: doesn't send anything, just records the last message sentMessages
- class method lastMessageSent returns the recorded message
"
Class {
	#name : #SMWebSocketMock,
	#superclass : #SMWebSocketHandler,
	#classVars : [
		'LastMessageSent'
	],
	#category : #SmallMuse
}

{ #category : #accessing }
SMWebSocketMock class >> lastMessageSent [
	^ LastMessageSent
]

{ #category : #running }
SMWebSocketMock class >> send: message to: sockets [
	LastMessageSent := message

]
