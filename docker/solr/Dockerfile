FROM solr:8.11.2
ARG CORE_NAME="spot"

ENV SOLR_CORES=spot
ENV SOLR_CORE_CONF_DIR=/spot-config
ENV SOLR_HOST=localhost
ENV SOLR_INCLUDE=/usr/local/share/solr/solr.in.sh

# store config in a conf/ subdirectory so solr uses it consistently
# (core was being created + configured to use memory store)
# see: https://stackoverflow.com/a/67536331
COPY --chown=solr:root config $SOLR_CORE_CONF_DIR/conf

# custom scripts to be run on solr inits
COPY --chown=solr:root scripts/*.sh /docker-entrypoint-initdb.d/

# custom env settings
COPY --chown=solr:root assets/solr.in.sh $SOLR_INCLUDE

COPY config $SOLR_CORE_CONF_DIR
COPY scripts/*.sh /docker-entrypoint-initdb.d/

USER root
RUN mkdir -p /var/ssl && chown ${SOLR_USER:-solr}:${SOLR_GROUP:-solr} /var/ssl
USER $SOLR_UID

HEALTHCHECK CMD curl https://localhost:8983/solr/ || exit 1
