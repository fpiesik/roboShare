cd /mnt/raspiShare/pySeq
sleep 5
#../pd-0.46-6rpi/bin/pd -alsamidi -mididev 1 -path ../pythagotron/code/software -path ../extra -path ../myExtra  -open ./Sequencer.pd &
pd -alsamidi -mididev 1 -path ../myExtra -path ../extra  -open ./pySeq.pd &
sleep 5
aconnect MPKmini2 'Pure Data'
aconnect 'nanoKEY Studio' 'Pure Data'
aconnect 'Pure Data':1 'pythagotron':0