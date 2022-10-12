FROM solr:8.11.2

ENV SOLR_CORES=spot
ENV SOLR_CORE_CONF_DIR=/spot-config
ENV SOLR_HOST=localhost

# store config in a conf/ subdirectory so solr uses it consistently
# (core was being created + configured to use memory store)
# see: https://stackoverflow.com/a/67536331
COPY --chown=solr:root config $SOLR_CORE_CONF_DIR/conf

# custom scripts to be run on solr inits
COPY --chown=solr:root scripts/*.sh /docker-entrypoint-initdb.d/

HEALTHCHECK CMD curl http://localhost:8983/solr/ || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr-foreground", "-c"]

