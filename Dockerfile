FROM openjdk:8 AS build
MAINTAINER BlueEnni

WORKDIR /data

ARG url=https://www.tekx.it/downloads/
ARG version=0.981Tekxit3Server
ARG jarfile=forge-1.12.2-14.23.5.2847-universal.jar
# Set memory size
ARG memory_size=4G
# Set Java Flags
ARG java_flags="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true -Dfml.queryResult=confirm"
ENV URL=$url
ENV VERSION=$version

#Downloading tekxitserver.zip
RUN wget ${URL}${VERSION}.zip \
#Downloading unzip\
&& apt-get update -y && apt-get install unzip wget -y --no-install-recommends \
#unziping the package\
&& unzip ${VERSION}.zip -d /data/ \
&& mv ${VERSION}/* /data/ \
&& rmdir ${VERSION} \
&& rm ${VERSION}.zip \
#accepting the eula\
&& touch eula.txt \
&& echo 'eula=true'>eula.txt

FROM adoptopenjdk/openjdk8:alpine-slim AS runtime
COPY --from=build /data /data
RUN apk add --no-cache bash
WORKDIR /data

ARG version=0.981Tekxit3Server
ARG jarfile=forge-1.12.2-14.23.5.2847-universal.jar
ARG memory_size=4G
ARG java_flags="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true -Dfml.queryResult=confirm"
ENV JAVAFLAGS=$java_flags
ENV MEMORYSIZE=$memory_size
ENV JARFILE=$jarfile
ENV VERSION=$version

# Expose minecraft port
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Entrypoint with java optimisations
ENTRYPOINT java -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE $JAVAFLAGS ./${VERSION}/${JARFILE} --nojline nogui
