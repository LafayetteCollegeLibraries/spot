# frozen_string_literal: true
module Spot
  module Renderers
    class ExternalAuthorityAttributeRenderer < FacetedAttributeRenderer
      private

        # External Authority attributes are expected to be sent in a "merged"
        # array of [uri, label]. FacetedAttributeRenderer#li_value is called
        # for the label.
        #
        # @param value [Array<String>]
        # @return [String]
        def li_value(value)
          uri, label = value

          %(#{super(label)} (#{external_authority_link(uri)}))
        end

        # @param uri [String]
        # @return [String]
        def external_authority_link(uri)
          link_to('view authority <span class="fa fa-external-link"></span>'.html_safe,
                  uri,
                  target: '_blank')
        end
    end
  end
end
