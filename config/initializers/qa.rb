# frozen_string_literal: true
#
# QuestioningAuthority configuration

# our Solr suggestion authorities
solr_suggestion_authorities = %w[
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
