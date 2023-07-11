# frozen_string_literal: true
#
# Attribute renderer for linked-data values. When initialized, it expects
# the +values+ parameter to be an array in the form of [uri, label].
#
# @example
#   values = [['https://www.carlyraemusic.com/', 'Carly Rae Jepsen']]
#   renderer = Spot::Renderers::ExternalAuthorityAttributeRenderer.new(:creator,
#                                                                      values,
#                                                                      search_field: :creator_label_ssim)
#   renderer.render
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

        # for locations without URI sources, we index the label as the uri.
        # in those cases, we'll just render a link to a faceted search.
        return super(label) if uri == label

        %(#{super(label)} (#{external_authority_link(uri)}))
      end

      # @param uri [String]
      # @return [String]
      def external_authority_link(uri)
        link_to('view authority <span class="fa fa-external-link"></span>'.html_safe,
                uri,
                target: '_blank',
                rel: 'noopener')
      end
    end
  end
end
