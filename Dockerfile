FROM openjdk:8 AS build
MAINTAINER BlueEnni

WORKDIR /data

ARG url=https://www.tekxit.xyz/downloads/
ARG version=0.990Tekxit3Server
ENV URL=$url
ENV VERSION=$version

#adding the fixed extrautils2.cfg and the entrypointscript to the container
COPY extrautils2.cfg \
entrypoint.sh ./
#Downloading tekxitserver.zip
RUN wget ${URL}${VERSION}.zip \
#Downloading unzip\
&& apt-get update -y && apt-get install unzip wget -y --no-install-recommends \
#unziping the package\
&& unzip ${VERSION}.zip -d /data/ \
&& mv ${VERSION}/* /data/ \
&& rmdir ${VERSION} \
&& rm ${VERSION}.zip \
#moving the fixed extrautils2.cfg into the configfolder\
&& mv extrautils2.cfg /data/config/ \
#accepting the eula\
&& touch eula.txt \
&& echo 'eula=true'>eula.txt

FROM adoptopenjdk/openjdk8:alpine-slim AS runtime
COPY --from=build /data /files
RUN apk add --no-cache bash \
&& chmod +x /files/entrypoint.sh
WORKDIR /data

ARG version=0.990Tekxit3Server
ARG jarfile=forge-1.12.2-14.23.5.2847-universal.jar
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
