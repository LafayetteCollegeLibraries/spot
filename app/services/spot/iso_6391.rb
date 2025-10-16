# frozen_string_literal: true
module Spot
  # Helper module for obtaining labels for ISO-639-1 values. Uses +I18n+ gem to allow
  # custom labels for languages to be provided as a locale file (see +config/locales/iso_639.en.yml+)
  module ISO6391
    # All of the ISO-639-1 entries in a key/val hash
    #
    # @example
    #   Spot::LanguageAuthority.all.first.to_h
    #   # => {'aa' => 'Afar'}
    #
    # @return [Array<Hash<String => String>>]
    def self.all
      @all ||= ISO_639::ISO_639_1.select { |e| e.alpha2.present? }.map { |e| [e.alpha2, label_for(e.alpha2)] }.to_h
    end

    # Find the label for a language by its 2-char entry.
    # Possible values, in priority order, are:
    #
    #   - locale value             => I18n.t('iso_639_1.es')
    #   - iso-639 gem english name => ISO_639.find('es').english_name
    #   - the id value as provided => 'es'
    #
    # @param [String] id
    # @return [String, NilClass]
    def self.label_for(id)
      id = id.to_s.downcase
      I18n.t(id, scope: ['iso_639_1'], default: [ISO_639.find(id)&.english_name, id])
    end
  end
end
