# frozen_string_literal: true
module Spot
  # Helper methods intended to be used within jbuilder settings
  module JsonHelper
    # Converts an array (or array-like thing that responds to +:to_a+) of
    # ControlledVocabulary objects into URIs
    #
    # @param [Array<String>, #to_a] raw_values
    # @return [Array<String>]
    def map_uris(raw_values)
      raw_values = raw_values.to_a if raw_values.respond_to?(:to_a)

      Array.wrap(raw_values).map do |raw|
        uri = raw.respond_to?(:rdf_subject) ? raw.send(:rdf_subject) : raw
        uri.to_s
      end
    end
  end
end
