# frozen_string_literal: true
module Spot
  module Renderers
    class FacetedAttributeRenderer < AttributeRenderer
      private

        # @param value [#to_s]
        # @return [String] the value linked to a faceted search
        def li_value(value)
          link_to(ERB::Util.h(value.to_s), search_path(value.to_s))
        end

        # creates a path to a faceted search
        #
        # @param value [String]
        # @return [String]
        def search_path(value)
          Rails.application.routes.url_helpers.search_catalog_path("f[#{search_field}][]": value,
                                                                   locale: I18n.locale)
        end

        # changed from +Hyrax::Renderers::AttributeRenderer+ to allow us to
        # pass a full search field to +options[:search_field]+ and fall back
        # to +solr_name+-ing the field (which was the original strategy).
        #
        # @return [String]
        def search_field
          field_name = options[:search_field]
          field_name ||= ActiveFedora.index_field_mapper.solr_name(field, :facetable, type: :string)

          ERB::Util.h(field_name)
        end
    end
  end
end
