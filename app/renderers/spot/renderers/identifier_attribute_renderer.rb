# frozen_string_literal: true
module Spot
  module Renderers
    class IdentifierAttributeRenderer < AttributeRenderer
    private

      # @param value [Spot::Identifier,String]
      # @return [String]
      def li_value(identifier)
        return %(<code>#{identifier}</code>) if options[:local] == true

        identifier = Spot::Identifier.from_string(identifier) if identifier.is_a? String
        [].tap do |html|
          html << prefix_tag(identifier.prefix_label) unless identifier.prefix.nil?
          html << identifier.value
        end.join(' ')
      end

      # @param label [String]
      # @return [String]
      def prefix_tag(label)
        %(<span class="label label-default">#{label}</span>)
      end
    end
  end
end
