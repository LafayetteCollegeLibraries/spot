#! /bin/bash
#
# boot up Solr + set up authentication for test user
bin/solr start
bin/solr auth enable -type basicAuth -credentials solr:SolrRocks -z $ZK_HOST
bin/solr stop