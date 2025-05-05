# frozen_string_literal: true
module Spot
  module QaAssignFastGenericAuthorityPatch
    extend ActiveSupport::Concern

    private

    def parse_authority_response(raw_response)
      results = raw_response.try(:[], 'response').try(:[], 'docs') || []

      results.map do |doc|
        index = Qa::Authorities::AssignFast.index_for_authority(subauthority)
        term = doc[index].first
        term += " (USE #{doc['auth']})" if doc['type'] == 'alt'
        fast_id = Array.wrap(doc['idroot']).first

        {
          fast_id: fast_id,
          id: "http://id.worldcat.org/fast/#{fast_id.gsub(/^fst/, '')}",
          label: term,
          type: doc['type'],
          value: doc['auth']
        }
      end
    end
  end
end
