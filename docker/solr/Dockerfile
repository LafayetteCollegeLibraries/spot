FROM solr:9.10.1

USER root
RUN apt-get update -y && apt-get upgrade -y
USER $SOLR_UID

ENV SOLR_CORES="spot"
ENV SOLR_CORE_CONF_DIR="/spot-config"
ENV SOLR_HOST="localhost"
ENV SOLR_INCLUDE="/usr/local/share/solr/solr.in.sh"

# As of Solr 9.8, we need to enable the use directives in lib/
# This also enables the analysis-extras module which is needed
# for some of the configured types.
ENV SOLR_OPTS="-Dsolr.config.lib.enabled=true -Dsolr.modules=analysis-extras"

# store config in a conf/ subdirectory so solr uses it consistently
# (core was being created + configured to use memory store)
# see: https://stackoverflow.com/a/67536331
COPY --chown=solr:solr config $SOLR_CORE_CONF_DIR/conf

# custom scripts to be run on solr inits
COPY --chown=solr:solr scripts/*.sh /docker-entrypoint-initdb.d/

# custom env settings
COPY --chown=solr:solr assets/solr.in.sh $SOLR_INCLUDE

ENTRYPOINT ["docker-entrypoint.sh"]

# add '--user-managed' flag to disable cloud mode while we use the single server approach
CMD ["solr-foreground"]

RUN bin/solr zk upconfig -n spot-development -d /var/solr/data/spot-development

RUN bin/solr zk upconfig -n spot-test -d /var/solr/data/spot-test

HEALTHCHECK CMD curl http://localhost:8983/solr/ || exit 1
