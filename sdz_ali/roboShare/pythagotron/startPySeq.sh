#!/bin/bash
cd /home/sdz/roboShare/pythagotron
pd -alsamidi -mididev 1,2 -path ../myExtra -path ../extra  -open ./pySeq.pd &
sleep 10
aconnect MPKmini2 'Pure Data'
aconnect 'nanoKEY Studio' 'Pure Data':0
aconnect 'Pure Data':2 'pythagotron':0
aconnect 'Pure Data':2 'UM-1':0
aconnect 'Pure Data':2 'ESI MIDIMATE eX':0
#aconnect 'TR-6S' 'Pure Data':1
aconnect 'Pure Data':2 'TR-6S'