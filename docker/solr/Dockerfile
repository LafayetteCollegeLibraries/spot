ARG SOLR_VERSION_TAG=8
FROM bitnami/solr:$SOLR_VERSION_TAG

ENV SOLR_CORES=spot
ENV SOLR_CORE_CONF_DIR=/spot-config
COPY --chown=solr:root config $SOLR_CORE_CONF_DIR

HEALTHCHECK CMD curl http://localhost:8983/solr/ || exit 1
