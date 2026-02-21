cd /home/sdz/Dropbox/roboShare/GHSeq
pd -alsamidi -mididev 1,2,3 -path ../extra -path ../myExtra -open ./GH-Remote.pd &
sleep 15
aconnect 'Arturia MiniLab mkII' 'Pure Data':0
aconnect 'Pure Data':3 'harpune':0
aconnect 'harpune' 'Pure Data':1
aconnect 'Client-128':0 'Pure Data':2
