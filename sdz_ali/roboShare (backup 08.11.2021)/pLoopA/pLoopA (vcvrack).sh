#!/bin/sh
jack_control eps realtime true
jack_control ds alsa
#jack_control dps device hw:CODEC_2,0
jack_control dps rate 48000
jack_control dps period 256
jack_control dps nperiods 2
#jack_control eps "a"
jack_control start
sleep 2

cd /mnt/raspiShare/pLoopA
#pd -rt -audioadddev "L-12 (hardware)" -inchannels 14 -outchannels 2  -open ./pLoopA.pd &
pd -rt -jack -inchannels 8 -outchannels 9  -open ./pLoopA.pd &
sleep 5
aconnect 'Pure Data':2 'Neutron':0 &
aconnect 'elektrocaster':0 'Pure Data':0 &
aconnect 'Pure Data':3 'elektrocaster':0 &

#cd /home/frank/Dropbox/Software/Audio/VCV-Rack/Rack-0.6.2b-lin/Rack/
cd /home/frank/Documents/Rack-1.1.1-lin/Rack/

./Rack &

sleep 4

jmess -D &

sleep 1

jack_connect "system:capture_1" "pure_data:input0"
jack_connect "system:capture_2" "pure_data:input1"
jack_connect "system:capture_3" "pure_data:input2"
jack_connect "system:capture_4" "pure_data:input3"
jack_connect "system:capture_5" "pure_data:input4"
jack_connect "system:capture_6" "pure_data:input5"
jack_connect "system:capture_7" "pure_data:input6"
jack_connect "system:capture_8" "pure_data:input7"

jack_connect "pure_data:output0" "VCV Rack:inport 0"
jack_connect "pure_data:output1" "VCV Rack:inport 1"
jack_connect "pure_data:output2" "VCV Rack:inport 2"
jack_connect "pure_data:output3" "VCV Rack:inport 3"
jack_connect "pure_data:output4" "VCV Rack:inport 4"
jack_connect "pure_data:output5" "VCV Rack:inport 5"
jack_connect "pure_data:output6" "VCV Rack:inport 6"
jack_connect "pure_data:output7" "VCV Rack:inport 7"

jack_connect "VCV Rack:outport 0" "system:playback_1"
jack_connect "VCV Rack:outport 1" "system:playback_2"
jack_connect "VCV Rack:outport 2" "system:playback_3"
jack_connect "VCV Rack:outport 3" "system:playback_4"

jack_connect "pure_data:output8" "system:playback_1"
jack_connect "pure_data:output8" "system:playback_2"




