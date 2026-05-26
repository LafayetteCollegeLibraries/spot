# frozen_string_literal: true
module Spot
  # iirc we switched the default defType in solr to work better with the
  # blacklight advanced-search plugin, or to have better default search
  # results? tbh it's lost to time, but Hyrax assumes a lucene default,
  # which is causing the pcdm_member_presenters_factory query to fail.
  #
  # @see https://github.com/samvera/hyrax/blob/hyrax-v5.2.0/app/presenters/hyrax/pcdm_member_presenter_factory.rb#L109-L119
  module LucenePatchForPcdmMemberPresentersFactory
    private

    def query_docs(generic_type: nil, ids: object.member_ids)
      query = "{!terms f=id}#{ids.join(',')}"

      if generic_type
        query += "{!term f=generic_type_si}#{generic_type}"
        # works created via ActiveFedora use the _sim field
        query += "{!term f=generic_type_sim}#{generic_type}"
      end

      Hyrax::SolrService
        .post(q: query, rows: 10_000, defType: 'lucene')
        .fetch('response')
        .fetch('docs')
    end
  end
end
