# frozen_string_literal: true
require 'cgi'

module Spot
  class OaiCollectionSolrSet < ::BlacklightOaiProvider::SolrSet
    class << self
      # Rewriting this method bc the faceting approach used in BlacklightOaiProvider::SolrSet
      # stopped working somewhere along the upgrade path. From the best I can surmise, the existing
      # search builder code used (via Spot::CatalogSearchBuilder + a long inheritance chain) will
      # limit the collection ids in a facet query to those available to the user
      #
      # @note if we wanted to limit which collections are being offered to the OAI service, this
      #       this is the location where that would happen.
      # @return [Array<Spot::OaiCollectionSolrSet]
      # def all
      #   query_args = { rows: 0, facet: true, 'facet.field': solr_fields, fq: [visibility_fq] }
      #   results = Hyrax::SolrService.query_result('', **query_args)
      #   response = Blacklight::Solr::Response.new(results, query_args.merge(q: ''))

      #   sets_from_facets(response.facet_fields) if response.facet_fields
      # end

      def sets_for(record)
        self.fields = CatalogController.blacklight_config.oai[:document][:set_fields] if @fields.nil?

        super
      end

      private

      # @todo is there a better way to pull the permission fq from somewhere else?
      def visibility_fq
        public_viz = ['read', 'discover'].map { |type| "{!terms f=#{type}_access_group_ssim}public" }
        "(#{public_viz.join(' OR ')})"
      end
    end

    def initialize(spec)
      super(spec)
    end

    # @note In a Valkyrized world, this would probably also work as below, but I'm going
    #       to rely on SolrService for now since it's faster when using ActiveFedora:
    #         def name
    #           @fetched_name ||= begin
    #           collection = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: @value)
    #           collection.title.first || "#{@label}: #{@value}"
    #         end
    def name
      @fetched_name ||= Hyrax::SolrService.search_by_id(collection_id).fetch('title_tesim', "#{@label}: #{@value}")
    end

    #
    def spec
      @spec ||= "collection_id:#{collection_id}"
    end

    private

    def collection_id
      @collection_id ||= label == 'collection_id' ? value : find_collection_id_by(title: value)
    end

    def find_collection_id_by(title:, collection_type_gid: default_collection_type)
      Hyrax.query_service
           .custom_queries
           .find_collections_by_type(global_id: collection_type_gid)
           .find { |collection| collection.title.include?(title) }
           &.id
    end

    def default_collection_type
      Hyrax::CollectionType.find_or_create_default_collection_type.to_global_id
    end
  end
end
