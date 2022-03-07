"
Mock object for SMWorld
- sets up mock websocket handler
- initializes minimal world (initWorld) instead of loading world file from disk
- disallows saving the world file
"
Class {
	#name : #SMWorldMock,
	#superclass : #SMWorld,
	#category : #SmallMuse
}

{ #category : #accessing }
SMWorldMock >> commandParser [
	^ commandParser
]

{ #category : #handlers }
SMWorldMock >> saveWorld [
	"Mock saveWorld doesn't actually save."
]

{ #category : #accessing }
SMWorldMock >> socketHandler [
	^ socketHandler
]

{ #category : #accessing }
SMWorldMock >> startWorld: name at: location on: port [
	counter := SMCounter new.
	homeDirectory := location asFileReference isAbsolute
		ifTrue: [ location asFileReference ]
		ifFalse:
			[ FileLocator imageDirectory asFileReference / location ].
	loggedInUsers := Dictionary new.
	socketHandler := SMWebSocketMock new muse: self.
	self initWorld
]
