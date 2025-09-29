# frozen_string_literal: true
module Spot
  # We made this patch because there are two places that the original ‘find’
  # method in Bulkrax was failing to perform. First, Bulkrax will display a link
  # to an imported work's record but the ObjectFactory appears to be searching
  # for a work's 'source_identifier' as the object's ID. The second is that the ‘find’
  # Method is what is used to match and object with a collection at ingest, also
  # using 'source_identifier' as the object's ID. We believe that both of these
  # problems arise from our setup being on Hyrax 3.6.0 and unvalkyrized, and
  # that we can retire this patch once larger upgrades are made. This patch adds
  # a new method, ‘find_by_source_identifier’, which is added to the front of the
  # queue of methods to try in ‘find’. Notably, ‘find_by_source_identifier’ does not
  # succeed when called during ingest to make the link, but for some reason truly
  # unknown to us, if this method is called before ‘search_by_identifier’, that
  # method then succeeds where it would typically fail. The order of those methods
  # being switched does not produce the same result, both methods fail in that case.
  # However, once the CreateRelationshipsJob stage is reached,
  # ‘find_by_source_identifier’ always succeeds where ‘search_by_identifier’ always
  # fails. Truly incomprehensible. Nonetheless, this order seems to fulfill all desired
  # functions.
  #
  # @see config/initializers/spot_overrides.rb
  module BulkraxObjectFactoryFindPatch
    extend ActiveSupport::Concern

    # We have to overwrite this behavior to add 'find_by_source_identifier'
    # to the queue of methods to try.
    #
    # @see https://github.com/samvera/bulkrax/blob/v9.1.0/app/factories/bulkrax/object_factory_interface.rb#L317-L325
    def find
      find_by_source_identifier || find_by_id || search_by_identifier || nil
    end

    module ClassMethods
      # This method modifies the search to query Solr for the work's
      # source_identifier and then returns the object if it's found.
      def find_by_source_identifier
        return unless attributes.key?('source_identifier') && attributes['source_identifier'].present?
        identifier = Array.wrap(attributes['source_identifier']).first
        id_doc = Hyrax::SolrService.get("source_identifier_ssim:#{identifier}", fl: ['id', 'source_identifier_ssim'], defType: 'lucene')
        id_doc = id_doc.try(:[], 'response').try(:[], 'docs')&.first
        return nil if id_doc.nil? || id_doc.try(:[], 'id').nil?

        ActiveFedora::Base.find(id_doc['id'])
      end

      # We have to implement these for testing purposes.
      def find_by_id
        super
      end

      def search_by_identifier
        super
      end
    end
  end
end
