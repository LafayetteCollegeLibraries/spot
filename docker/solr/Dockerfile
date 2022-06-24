FROM solr:8
ARG CORE_NAME="spot"

# NOTE we can't do this, as COPY and ADD can't go outside the context
COPY ../../solr/config /spot-config
RUN precreate-core $CORE_NAME /spot-config

# @todo run in cloud mode?
