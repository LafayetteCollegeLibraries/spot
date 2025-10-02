#! /bin/bash
#
# enable basic authentication by uploading a security config to zookeeper
/opt/solr/server/scripts/cloud-scripts/zkcli.sh \
  -zkhost $ZK_HOST \
  -cmd put /security.json '{"authentication":{
   "class":"solr.BasicAuthPlugin",
   "credentials":{"solr":"IV0EHq1OnNrj6gvRCwvFwTrZ1+z1oBbnQdiVC3otuq0= Ndd7LKvVBAaZIF0QAVi1ekCfAJXr1GGfLtRUXhgrF8c="}
},"authorization":{
   "class":"solr.RuleBasedAuthorizationPlugin",
   "permissions":[{"name":"all", "role":"admin"}],
   "user-role":{"solr":"admin"}
}}'