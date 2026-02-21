#!/bin/bash
cd /home/frank/Dropbox/roboShare/roboMaster
pd -alsamidi -mididev 1,2,3,4 -path ../extra -path ../myExtra -open ./roboMaster.pd 
#sleep 15
#//aconnect 'Midi Through' 'Pure Data':0
#aconnect 'WIDI Uhost' 'Pure Data':1 
#aconnect 'keyfoot' 'Pure Data':1
#aconnect 'Pure Data':4 'WIDI Uhost'
#aconnect 'Pure Data':5 'GT-1000':0
#aconnect 'Pure Data':6 'UM-1':0
#aconnect 'Pure Data':5 'Neutron(1)':0
#aconnect 'Pure Data':7 'Neutron(1)':0
