ARG SOLR_VERSION_TAG=8.11.2
FROM solr:$SOLR_VERSION_TAG

ENV SOLR_CORES=spot
ENV SOLR_CORE_CONF_DIR=/spot-config
ENV SOLR_HOST=localhost

COPY config $SOLR_CORE_CONF_DIR
COPY scripts/*.sh /docker-entrypoint-initdb.d/

HEALTHCHECK CMD curl https://localhost:8983/solr/ || exit 1
