# frozen_string_literal: true
#
# A light class used to provide a +questioning_authority+ endpoint
# to search ISO-639-1 languages. See {Spot::ISO6391} for details.
module Qa::Authorities
  class Language < Qa::Authorities::Base
    # @return [Array<Hash<Symbol => String>>]
    def all
      @@all ||= Spot::ISO6391.all.map { |key, val| wrap(id: key, label: val) }
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

    def wrap(id:, label:)
      return if id.nil? || label.nil?

      { id: id, label: label, value: id }
    end
  end
end
