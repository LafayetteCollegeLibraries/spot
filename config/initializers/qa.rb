# frozen_string_literal: true
#
# QuestioningAuthority configuration

# our Solr suggestion authorities
solr_suggestion_authorities = %w[
  bibliographic_citation
  keyword
  name
  organization
  physical_medium
  publisher
  source
]

solr_suggestion_authorities.each do |subauth|
  Qa::Authorities::Local.register_subauthority(subauth, 'Qa::Authorities::SolrSuggest')
end

Qa::Authorities::Local.register_subauthority('lafayette_instructors', 'Qa::Authorities::Local::TableBasedAuthority')
