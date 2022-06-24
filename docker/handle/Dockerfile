# Building our own Dockerfile for the Handle service
# as the one from datacite is 4 years without an update.
# I'll be using that one as a template, however.
# @see: https://github.com/datacite/docker-handle/blob/master/Dockerfile
#
# instead of using python to translate ENV values into a config
# file, we'll use gnu's `envsubst` which does the same thing.
#
# note that this is being built to use postgresql as the storage backend

# 1. use jdk base image
# 2. install dependencies (apt-get i think)
#    - envsubst
# 3. download handle jar from handle.net
#    -  http://www.handle.net/hnr-source/handle-9.2.0-distribution.tar.gz
# 4. unzip + put in place
# 5. use entrypoint to generate config files from ENV values
#    `cat config.json.template | envsubst > config.json`

FROM openjdk:18-jdk-slim-buster

RUN apt-get update && \
    apt-get install -y curl gettext libpostgresql-jdbc-java && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HANDLE_SERVER_HOME=/hdl-server

WORKDIR $HANDLE_SERVER_HOME

ARG HANDLE_VERSION=9.3.0

# set this env for reference when inspecting the container
ENV HANDLE_VERSION=$HANDLE_VERSION

RUN curl -s http://www.handle.net/hnr-source/handle-$HANDLE_VERSION-distribution.tar.gz | \
      tar -xz -C $HANDLE_SERVER_HOME --strip-components=1

# setup postgresql as the database driver
# trying jdbc3 as that's the version mentioned in the documentation
# (see pg 50 of handle v9 documentation: http://www.handle.net/tech_manual/HN_Tech_Manual_9.pdf)
RUN ln -s /usr/share/java/postgresql-jdbc3.jar $HANDLE_SERVER_HOME/lib/postgresql-jdbc3.jar

# Redirect log files to stdout/stderr
RUN ln -sf /dev/stdout $HANDLE_SERVER_HOME/logs/access.log && \
    ln -sf /dev/stderr $HANDLE_SERVER_HOME/logs/error.log

# deal with scripts after downloading + extracting the handle service
# so we can rely on the docker cache to prevent redownloading during dev
COPY scripts /hdl-scripts
COPY templates /hdl-templates
RUN chmod +x /hdl-scripts/docker-entrypoint.sh

ENTRYPOINT ["/hdl-scripts/docker-entrypoint.sh"]
CMD ["/bin/bash", "-c", "$HANDLE_SERVER_HOME/bin/hdl-server $HANDLE_SERVER_HOME"]
