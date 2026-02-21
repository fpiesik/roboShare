#!/bin/bash
cd /home/sdz/Dropbox/roboShare/ElektroCaster
pd -alsamidi -mididev 1,2,3,4 -path ../extra -path ../myExtra -open ./EC-Remote.pd &
sleep 10
//aconnect 'Midi Through' 'Pure Data':0
aconnect 'elektrocaster' 'Pure Data':1 
aconnect 'keyfoot' 'Pure Data':1
aconnect 'Pure Data':4 'elektrocaster'
aconnect 'Pure Data':5 'GT-1000':0
