#!/bin/bash
mv /files/!(entrypoint.sh) /data
# Start the java process
/opt/java/openjdk/bin/java -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE $JAVAFLAGS /data/${JARFILE} --nojline nogui
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start java -jar: $status"
fi