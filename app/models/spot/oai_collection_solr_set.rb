# frozen_string_literal: true
module Spot
  # OAI sets for collections. We're using 'member_of_collection_ids_ssim' as the
  # setSpec hook, and we're querying the document to get the title (blacklight_oai_provider
  # uses faceting to quickly get results and that limits us to what data we'll get back from
  # the query.)
  #
  # @todo is there a more efficient way to get the title rather than querying solr per-item?
  class OaiCollectionSolrSet < ::BlacklightOaiProvider::SolrSet
    def self.sets_for(record)
      @fields = CatalogController.blacklight_config.oai[:document][:set_fields] if @fields.nil?

      super(record)
    end

    def name
      @name ||= "#{@label.titleize}: #{title_from_document}"
    end

    private

      def title_from_document
        doc = SolrDocument.find(@value)
        doc&.title&.first || @value.titleize
      end
  end
end
