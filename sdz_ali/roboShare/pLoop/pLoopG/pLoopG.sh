cd /mnt/raspiShare/pLoopG
#pd -rt ./pLoopA.pd &
#sleep 12
pd -noaudio -path ../extra -path ../myExtra -open ./pLoopG.pd 
