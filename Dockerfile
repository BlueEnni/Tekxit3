FROM openjdk:8 AS build
MAINTAINER BlueEnni

WORKDIR /data

ARG url=https://tekxit.xyz/downloads/
ARG version=0.13.2TekxitPiServer
ENV URL=$url
ENV VERSION=$version

#adding the entrypointscript to the container
COPY entrypoint.sh ./
#Downloading tekxitserver.zip
RUN wget ${URL}${VERSION}.zip \
#Downloading unzip\
&& apt-get update -y && apt-get install unzip wget -y --no-install-recommends \
#unziping the package\
&& unzip ${VERSION}.zip -d /data/ \
&& mv ${VERSION}/* /data/ \
&& rmdir ${VERSION} \
&& rm ${VERSION}.zip \
#downloading the Sampler mod for stall reports \
&& wget https://media.forgecdn.net/files/2707/159/sampler-1.84.jar \
&& mv sampler-1.84.jar /data/mods/ \
#downloading the backupmod\
&& wget https://media.forgecdn.net/files/2819/669/FTBBackups-1.1.0.1.jar \
&& mv FTBBackups-1.1.0.1.jar /data/mods/ \
&& wget https://media.forgecdn.net/files/2819/670/FTBBackups-1.1.0.1-sources.jar \
&& mv FTBBackups-1.1.0.1-sources.jar /data/mods/ \
#accepting the eula\
&& touch eula.txt \
&& echo 'eula=true'>eula.txt

FROM adoptopenjdk/openjdk8:alpine-slim AS runtime
COPY --from=build /data /files
RUN apk add --no-cache bash \
&& chmod +x /files/entrypoint.sh
WORKDIR /data

ARG version=0.13.2TekxitPiServer
ARG jarfile=forge-1.12.2-14.23.5.2854.jar
ARG memory_size=4G
ARG timezone=Europe/Berlin
ARG java_flags="-Dfml.queryResult=confirm"
ENV JAVAFLAGS=$java_flags
ENV MEMORYSIZE=$memory_size
ENV JARFILE=$jarfile
ENV VERSION=$version
ENV TIMEZONE=$timezone

# Expose minecraft port
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Entrypoint script for container start
ENTRYPOINT /files/entrypoint.sh