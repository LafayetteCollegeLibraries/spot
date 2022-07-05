FROM solr:8
ARG CORE_NAME="spot"

COPY config /spot-config
RUN precreate-core $CORE_NAME /spot-config
