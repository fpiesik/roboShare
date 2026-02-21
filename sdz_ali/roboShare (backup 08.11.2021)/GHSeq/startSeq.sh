#cd /mnt/raspiShare/pySeq
cd /home/pi/Desktop/raspiShare/GHSeq

#../pd-0.46-6rpi/bin/pd -noprefs -alsamidi -mididev 1 -path ../pythagotron/code/software -path ../extra -path ../myExtra  -open ./Sequencer.pd &
pd -alsamidi -mididev 1 -font-size 20 -path ../myExtra -path ../extra  -open ./Sequencer3.pd &
sleep 5
aconnect LPK25 'Pure Data'
aconnect 'Pure Data':1 'USB Uno MIDI Interface'