cd /home/pi/roboShare/SeqTop
#cd /home/pi/Desktop/raspiShare/GHSeq

pd -noprefs -audiobuf 1 -alsamidi -mididev 1,2,3,4 -path ../extra -path ../myExtra -open ./SeqTop.pd &
sleep 5
#aconnect 'Arturia KeyStep 32' 'Pure Data':0
#aconnect 'Pure Data':5 'elektrocaster'
aconnect 'Pure Data':4 'Neutron(1)'
#aconnect 'Pure Data':4 'UM-1'
#aconnect 'Pure Data':6 'Arturia KeyStep 32'
aconnect 129:0 'Pure Data':0
aconnect 130:0 'Pure Data':0