# frozen_string_literal: true

# An utility class for the +iso-639+ gem. We're storing the dictionary
# in a class variable so we don't need to load it every time.
module Spot
  module ISO6391
    OVERRIDES = {
      'es' => 'Spanish'
    }.freeze

    # All of the ISO-639-1 entries in a key/val hash
    #
    # @example
    #   Spot::LanguageAuthority.all.first.to_h
    #   # => {'aa' => 'Afar'}
    #
    # @return [Array<Hash<String => String>>]
    def self.all
      @all ||= ISO_639::ISO_639_1.select { |e| e.alpha2.present? }.map { |e| [e.alpha2, e.english_name] }.to_h
    end

    # Find the label for a language by its 2-char entry.
    #
    # @param [String] id
    # @return [String, NilClass]
    def self.label_for(id)
      id = id.to_s.downcase
      OVERRIDES[id] || all[id]
    end
  end
end
