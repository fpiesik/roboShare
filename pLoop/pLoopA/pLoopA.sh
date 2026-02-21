cd /mnt/raspiShare/pLoopA
#pd -rt -audioadddev "L-12 (hardware)" -inchannels 14 -outchannels 2  -open ./pLoopA.pd &
pd -rt -jack -inchannels 8 -outchannels 8  -open ./pLoopA.pd &
sleep 5
aconnect 'Pure Data':2 'Neutron':0



