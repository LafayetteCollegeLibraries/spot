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
      find_by_source_identifier || find_by_id|| search_by_identifier || nil
    end

    def find_by_source_identifier
      # Hyrax.logger.warn("find_by_source_identifier")
      return unless attributes.key?('source_identifier') && attributes['source_identifier'].present?
      # Hyrax.logger.warn("continue")
      identifier = Array.wrap(attributes['source_identifier']).first
      # Hyrax.logger.warn(identifier)
      id_doc = Hyrax::SolrService.get("source_identifier_ssim:#{identifier}", fl: ['id', 'source_identifier_ssim'], defType: 'lucene')
      # Hyrax.logger.warn(id_doc.to_s)
      id_doc = id_doc.try(:[], 'response').try(:[], 'docs')&.first
      # Hyrax.logger.warn(id_doc.to_s)
      return nil if id_doc.nil? || id_doc.try(:[], 'id').nil?

      ActiveFedora::Base.find(id_doc['id'])
    end

    # def find_by_id
    #   Hyrax.logger.warn("find_by_id")
    #   return false if attributes[:id].blank?
    #   Hyrax.logger.warn("continue")
    #   # Rails / Ruby upgrade, we moved from :exists? to :exist?  However we want to continue (for a
    #   # bit) to support older versions.
    #   method_name = klass.respond_to?(:exist?) ? :exist? : :exists?
    #   Hyrax.logger.warn("method name - " + method_name.to_s)
    #   klass.find(attributes[:id]) if klass.send(method_name, attributes[:id])
    # rescue Valkyrie::Persistence::ObjectNotFoundError
    #   Hyrax.logger.warn("valkyrie error")
    #   false
    # end

    # def find_by_id_alt
    #   Hyrax.logger.warn("find_by_id_alt")
    #   return unless attributes.key?('id') && attributes['id'].present?
    #   Hyrax.logger.warn("continue")
    #   ActiveFedora::Base.find(attributes['id'])
    # end

    # def search_by_identifier
    #   Hyrax.logger.warn("find_by_source_identifier")
    #   return false if source_identifier_value.blank?
    #   Hyrax.logger.warn("continue")
    #   Hyrax.logger.warn("klass - " + klass.to_s)
    #   Hyrax.logger.warn("work_identifier_search_field - " + work_identifier_search_field.to_s)
    #   Hyrax.logger.warn("source_identifier_value - " + source_identifier_value.to_s)
    #   Hyrax.logger.warn("work_identifier - " + work_identifier.to_s)
    #   self.class.search_by_property(
    #     klass: klass,
    #     search_field: work_identifier_search_field,
    #     value: source_identifier_value,
    #     name_field: work_identifier
    #   )
    # end
  end
end
