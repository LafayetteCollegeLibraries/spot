# frozen_string_literal: true
module Spot
  # Bulkrax will display a link to an imported work's record but the ObjectFactory
  # appears to be searching for a work's 'source_identifier' as the object's ID.
  # This modifies the search to query Solr for the work's source_identifier and
  # then return the object if it's found.
  #
  # @see config/initializers/spot_overrides.rb
  module BulkraxObjectFactoryFindPatch
    extend ActiveSupport::Concern

    # For some reason, just overwriting :find_by_identifier wasn't working,
    # so we'll write over the :find method to try finding by source_identifier
    # first and then otherwise fall back to Bulkrax behavior.
    #
    # @see https://github.com/samvera/bulkrax/blob/v9.1.0/app/factories/bulkrax/object_factory_interface.rb#L317-L325
    def find
      find_by_source_identifier || super
    end

    def find_by_source_identifier
      sleep (2)
      Hyrax.logger.warn("find - source_identifier")
      return unless attributes.key?('source_identifier') && attributes['source_identifier'].present?
      Hyrax.logger.warn("continue")
      self.class.find(Array.wrap(attributes['source_identifier']).first)
    end

    def find_by_id
      Hyrax.logger.warn("find - id")
      return unless attributes.key?('id') && attributes['id'].present?
      Hyrax.logger.warn("continue")
      ActiveFedora::Base.find(attributes['id'])
    end

    module ClassMethods
      # @see https://github.com/samvera/bulkrax/blob/v9.1.0/app/factories/bulkrax/object_factory.rb#L57-L64
      # @see https://github.com/samvera/bulkrax/blob/v9.1.0/app/factories/bulkrax/object_factory_interface.rb#L164-L168
      def find(identifier)
        Hyrax.logger.warn("find - identifier")
        Hyrax.logger.warn(identifier)
        id_doc = Hyrax::SolrService.get("source_identifier_ssim:#{identifier}", fl: ['id', 'source_identifier_ssim'], defType: 'lucene')
        Hyrax.logger.warn(id_doc.to_s)
        id_doc = id_doc.try(:[], 'response').try(:[], 'docs')&.first
        Hyrax.logger.warn(id_doc.to_s)
        return super(identifier) if id_doc.nil? || id_doc.try(:[], 'id').nil?

        ActiveFedora::Base.find(id_doc['id'])
      end
    end
  end
end
