# SmallMuse
A Multi-User Shared Environment in SmallTalk

## Installation
Installation with dependencies via Iceberg isn't working yet. In the meantime, you must explicitly load the dependencies:

### Zinc WebSockets
```smalltalk
Gofer new
   smalltalkhubUser: 'SvenVanCaekenberghe' project: 'ZincHTTPComponents';
   package: 'ConfigurationOfZincHTTPComponents';
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
```smalltalk
Gofer new
    renggli: 'petit'; 
    package: 'PetitParser';
    load.
```
