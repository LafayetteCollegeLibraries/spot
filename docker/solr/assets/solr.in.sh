# Disable LargePages to help prevent out of memory errors
# Add Base64 flag to mitigate 20261118-java4shell vulnerability
SOLR_OPTS="$SOLR_OPTS -XX:-UseLargePages -XX:-UseBASE64Intrinsics"
