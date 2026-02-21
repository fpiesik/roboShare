cd /home/pi/roboShare/pLoop
puredata -rt -open ./pLoopA/pLoopA.pd &
sleep 2
puredata -noaudio -open ./pLoopG/pLoopG.pd &
sleep 2
/home/pi/opt/REAPER/reaper &
sleep 2
a2jmidid &
sleep 6
#aconnect 'Pure Data':2 'Neutron':0
