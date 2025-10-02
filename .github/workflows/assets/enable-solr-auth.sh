#! /bin/bash
#
# boot up Solr + set up authentication for test user
/opt/solr/bin/solr start
/opt/solr/bin/solr auth enable -type basicAuth -credentials solr:SolrRocks -z $ZK_HOST
/opt/solr/bin/solr stop