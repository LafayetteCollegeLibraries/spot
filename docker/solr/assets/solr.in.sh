# Disable LargePages to help prevent out of memory errors
SOLR_OPTS="$SOLR_OPTS -XX:-UseLargePages"
ZK_HOST=zoo:2181