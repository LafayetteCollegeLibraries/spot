# frozen_string_literal: true
#
# QuestioningAuthority configuration

# our Solr suggestion authorities
Qa::Authorities::Local.register_subauthority('keywords', 'KeywordSuggest')
Qa::Authorities::Local.register_subauthority('sources', 'SourceSuggest')
Qa::Authorities::Local.register_subauthority('publishers', 'PublisherSuggest')
