cd /mnt/raspiShare/pLoop
pd -rt ./pLoopA.pd &
sleep 4 &
pd -noaudio -path ../extra -path ../myExtra -open ./pLoopG.pd 
