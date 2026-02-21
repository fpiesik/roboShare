#!/bin/bash
cd /home/frank/Dropbox/roboShare/audioServer
pd -alsamidi -mididev 1,2,3,4 -path ../extra -path ../myExtra -open ./audioServer.pd 

