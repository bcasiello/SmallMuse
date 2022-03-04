# SmallMuse
A Multi-User Shared Environment in SmallTalk

## Installation
I don't have installation with dependencies via Iceberg working yet. Until I figure that out, you must explicitly load the dependencies:

### Zinc WebSockets
```smalltalk
Metacello new
  repository: 'github://svenvc/zinc/repository';
  baseline: 'ZincHTTPComponents';
  load.
(Smalltalk globals at: #ConfigurationOfZincHTTPComponents) project latestVersion load: 'WebSocket'.
```

### Mustache templates
```smalltalk
Gofer it
   smalltalkhubUser: 'NorbertHartl' project: 'Mustache';
   configuration;
   loadStable.
```

### PetitParser
#### Note: PetitParser is no longer used.
```smalltalk
Gofer new
    renggli: 'petit'; 
    package: 'PetitParser';
    load.
```

### SmallMuse installation
Now you can install SmallMuse via Iceberg, pointing it at this repository.

### Creating a world

First, you need a directory to hold the world file, templates, and other configuration.
While developing, a convenient place is a subdirectory of your Pharo image, then you can just use a relative path when you start the world.
For production, you'll need a location where Pharo has write access.

## Usage
SMWorld is the main class that describes a SmallMuse world, so you start by creating one.
You then send it the message startWorld:&#8203;at:&#8203;on:
The first argument is the name of the world; used in messages to users.
The second is the location (directory) of the world file. If it's an absolute location, it's the full path to the directory. Otherwise, it's relative to the Smalltalk image path. The world file will be named world.ston in that directory. If the world file doesn't exist, one will be created with a tiny sample world. It is an error if the directory does not exist.

The third is the IP port you want to run on.

Run the following in a playground to start the server

```smalltalk
| myWorld |
myWorld := SMWorld new.
myWorld startWorld: 'TestMuse' at: 'testmuse' on: 4242.
```

then visit [http://localhost:4242/smallmuse](http://localhost:4242/smallmuse).
