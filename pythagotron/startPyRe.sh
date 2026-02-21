#!/bin/bash
#cd /home/sdz/roboShare/pythagotron
pd -alsamidi -mididev 1 -path ../myExtra -path ../extra  -open ./pyRemote.pd &
sleep 15
aconnect MPKmini2 'Pure Data'
aconnect 'nanoKEY Studio' 'Pure Data'
aconnect 'Pure Data':1 'pythagotron':0