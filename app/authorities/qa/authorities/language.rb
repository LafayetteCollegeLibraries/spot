# frozen_string_literal: true
#
# A light class used to provide a +questioning_authority+ endpoint
# to search ISO-639-1 languages. See {Spot::ISO6391} for details.
module Qa::Authorities
  class Language < Qa::Authorities::Base
    class_attribute :all

    # All of the languages available from the {Spot::ISO6391} service mapped
    # to a JSON format that QA expects.
    #
    # @return [Array<Hash<Symbol => String>>]
    def all
      Spot::ISO6391.all.map { |key, val| wrap(id: key, label: val) }
    end

    # @param [String] id
    # @return [Hash<Symbol => String>, NilClass]
    def find(id)
      wrap(id: id, label: Spot::ISO6391.label_for(id))
    end

    # @param [String] query
    # @return [Array<Hash<Symbol => String>>]
    def search(query)
      q_reg = Regexp.new(query.downcase, :i)
      Spot::ISO6391.all
                   .select { |_key, label| label.match? q_reg }
                   .map { |key, label| wrap(id: key, label: label) }
                   .compact # just in case
    end

    private

      # Wraps our results in a nice JSON response
      #
      # @param [String] id
      # @param [String] label
      # @return [Hash<Symbol => String>]
      def wrap(id:, label:)
        return if id.nil? || label.nil?

        { id: id, label: label, value: id }
      end
  end
end
