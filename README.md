# Relay Console
![screenshot 1](http://www.vercas.com/wp-content/uploads/2014/01/Relay-Console-1.png "screenshot 1")

### Introduction
Relay console allows server administrators to remotely view and interact with the server console.

## Usage

The console opens when the standard in-game console is opened. By default all users in the group "owner" have full access to the console.  

### ULX
If you have ULX installed, all administrators can see the console, engine spew and server-/client-side errors.  
Super administrators can run RCon commands and serverside Lua.  

The [ulx group permissions menu](https://hostr.co/spJgT4MnCrbg) or the corresponding console commands can be used to add more finegrained control through the following permissions:  
- relayc show
- relayc spew
- relayc rcon
- relayc luasv
- relayc sverrors
- relayc clerrors

I highly recommend tuning these permissions and being careful with the spew/errors. They might contain information that isn't for all eyes.

## Requirements
- Optional; to view errors: [gm_luaerror2](https://bitbucket.org/tuestu1/gm_luaerror2/downloads);
- Optional; to capture all the engine spew: [gm_enginespew](http://christopherthorne.googlecode.com/svn/trunk/gm_enginespew/Release/).

Make sure you rename the module(s) appropriately when necessary.
