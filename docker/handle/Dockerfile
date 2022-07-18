# Building our own Dockerfile for the Handle service
# as the one from datacite is 4 years without an update.
# I'll be using that one as a template.
#
# @see https://github.com/datacite/docker-handle
#
# NOTE: this uses bdbjc as the storage backend. Mount a volume at /data.
FROM openjdk:18-jdk-slim-buster

# set HANDLE_VERSION as an environment variable
# so we can inspect it from outside the container
ARG HANDLE_VERSION=9.3.0
ENV HANDLE_VERSION=$HANDLE_VERSION

ENV HANDLE_SERVER_HOME=/hdl-server
WORKDIR $HANDLE_SERVER_HOME

# downloading the source via ADD allows us to avoid installing curl
ADD https://www.handle.net/hnr-source/handle-$HANDLE_VERSION-distribution.tar.gz $HANDLE_SERVER_HOME/hdl-source.tar.gz
RUN tar -xz -C $HANDLE_SERVER_HOME --strip-components=1 -f $HANDLE_SERVER_HOME/hdl-source.tar.gz \
    && rm $HANDLE_SERVER_HOME/hdl-source.tar.gz

# Redirect log files to stdout/stderr
RUN mkdir -p $HANDLE_SERVER_HOME/logs \
    && ln -sf /dev/stdout $HANDLE_SERVER_HOME/logs/access.log \
    && ln -sf /dev/stderr $HANDLE_SERVER_HOME/logs/error.log

ENV PATH="$HANDLE_SERVER_HOME/bin:$PATH"

VOLUME /data

EXPOSE 2641/tcp
EXPOSE 8000/tcp

# deal with scripts after downloading + extracting the handle service
# so we can rely on the docker cache to prevent redownloading during dev
COPY scripts /hdl-scripts
RUN chmod +x /hdl-scripts/docker-entrypoint.sh

ENTRYPOINT ["/hdl-scripts/docker-entrypoint.sh"]
CMD ["/bin/bash", "-c", "hdl-server $HANDLE_SERVER_HOME"]
