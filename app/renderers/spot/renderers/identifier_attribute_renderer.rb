# frozen_string_literal: true
module Spot
  module Renderers
    class IdentifierAttributeRenderer < AttributeRenderer
      private

        # @param value [Spot::Identifier,String]
        # @return [String]
        def li_value(identifier)
          identifier = Spot::Identifier.from_string(identifier) if identifier.is_a? String

          [].tap do |html|
            html << prefix_tag(identifier.prefix) unless identifier.prefix.nil?
            html << identifier.value
          end.join(' ')
        end

        # @param prefix [String]
        # @return [String]
        def prefix_tag(prefix)
          %(<span class="label label-default">#{label_for(prefix)}</span>)
        end

        # @param prefix [String]
        # @return [String]
        def label_for(prefix)
          Spot::Identifier.prefix_label(prefix)
        end
    end
  end
end
