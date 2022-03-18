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

# Subclassing QA's TableBasedAuthority to include active entries, something we're reseting
# with each load of the authority to ensure that only currently active instructors are loaded
# without deleting previous entries for historical purposes.
#
# see {Spot::LafayetteInstructorsAuthorityService#load}
module Spot
  class LocalTableBasedAuthority < ::Qa::Authorities::Local::TableBasedAuthority

    private

    def base_relation
      Qa::LocalAuthorityEntry.where(local_authority: local_authority, active: true)
    end
  end
end

Qa::Authorities::Local.register_subauthority('lafayette_instructors', 'Spot::LocalTableBasedAuthority')
