FROM openjdk:8 AS build
MAINTAINER BlueEnni

WORKDIR /data

ARG url=https://tekxit.xyz/downloads/
ARG version=1.0.3TekxitPiServer
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

ENV VERSION=1.0.3TekxitPiServer
ENV JARFILE=forge-1.12.2-14.23.5.2854.jar
ENV MEMORYSIZE=4G
ENV TIMEZONE=Europe/Berlin
ENV JAVAFLAGS="-Dfml.queryResult=confirm"

# Expose minecraft port
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Entrypoint script for container start
ENTRYPOINT /files/entrypoint.sh