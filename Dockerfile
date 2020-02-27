FROM alpine:3.11.3

LABEL maintainer "Alex Khursevich <alex@qaprosoft.com>"

ENV DEBIAN_FRONTEND=noninteractive

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#==================
RUN apk add --no-cache \
    bash \
    openjdk8 \
    ca-certificates \
    tzdata \
    unzip \
    curl \
    wget \
    qt5-qtbase-dev \
    xvfb-run \
    socat \
    git \
    openssh \
    bind-tools
RUN rm -rf /var/lib/apt/lists/*

#===============
# Install Docker
#===============
RUN apk add --no-cache docker openrc
RUN rc-update add docker boot

#===============
# Install Maven 3.5.2
#===============
RUN cd /opt && \
    wget https://archive.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.zip && \
    unzip apache-maven-3.5.2-bin.zip && \
    rm apache-maven-3.5.2-bin.zip && \
    mv apache-maven-3.5.2/ maven/

#===============
# Set JAVA_HOME and M2_HOME
#===============
ENV JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk/" \
    M2_HOME="/opt/maven" \
    MAVEN_HOME="/opt/maven"
ENV PATH=$PATH:$JAVA_HOME/bin:$M2_HOME/bin

#======================
# Install Jenkins swarm
#======================
ENV JENKINS_SLAVE_ROOT="/opt/jenkins"

USER root

RUN mkdir -p "$JENKINS_SLAVE_ROOT"
RUN mkdir -p /opt/apk

# Slave settings
ENV JENKINS_MASTER_USERNAME="jenkins" \
    JENKINS_MASTER_PASSWORD="jenkins" \
    JENKINS_MASTER_URL="http://jenkins:8080/" \
    JENKINS_SLAVE_MODE="exclusive" \
    JENKINS_SLAVE_NAME="swarm-$RANDOM" \
    JENKINS_SLAVE_WORKERS="1" \
    JENKINS_SLAVE_LABELS="" \
    AVD=""

# Set the lang, you can also specify it as as environment variable through docker-compose.yml
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8\
    LC_ALL=en_US.UTF-8

# Install Jenkins slave (swarm)
ADD swarm.jar /
ADD entrypoint.sh /
#RUN chmod 777 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]