#!/bin/bash

cd /home/frank/Dropbox/roboShare/pLoop
pd -rt -open ./pLoopA/pLoopA.pd &
sleep 2
pd -noaudio -open ./pLoopG/pLoopG.pd &
sleep 2
#/home/pi/opt/REAPER/reaper &
#sleep 2
#a2jmidid &
#sleep 6
#aconnect 'Pure Data':2 'Neutron':0
