cd /home/pi/roboShare/GHSeq

pd -noprefs -alsamidi -mididev 1,2,3 -path ../extra -path ../myExtra -open ./GHSeq.pd &
sleep 5
aconnect 'Arturia MiniLab mkII' 'Pure Data':0
aconnect 'Pure Data':3 'harpune':0
aconnect 'harpune' 'Pure Data':1
aconnect 'Client-128':0 'Pure Data':2