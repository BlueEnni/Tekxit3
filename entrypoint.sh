#!/bin/bash
#copy files to mounted folder /data
shopt -s extglob
mv /files/!(entrypoint.sh) /data
rm -R /files/!(entrypoint.sh)
#add timezone
apk add tzdata
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
apk del tzdata
# Start the java process
/opt/java/openjdk/bin/java -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE $JAVAFLAGS /data/${JARFILE} --nojline nogui
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start java -jar: $status"
fi