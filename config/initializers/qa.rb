# frozen_string_literal: true
#
# QuestioningAuthority configuration

# our Solr suggestion authorities
Qa::Authorities::Local.register_subauthority('keyword', 'Qa::Authorities::SolrSuggest')
Qa::Authorities::Local.register_subauthority('source', 'Qa::Authorities::SolrSuggest')
Qa::Authorities::Local.register_subauthority('publisher', 'Qa::Authorities::SolrSuggest')
