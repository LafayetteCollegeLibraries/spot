# frozen_string_literal: true
module Spot
  # Helper module for obtaining labels for ISO-639-1 values. Uses +I18n+ gem to allow
  # custom labels for languages to be provided as a locale file (see +config/locales/iso_639.en.yml+)
  class Iso6391
    # All of the ISO-639-1 entries in a key/val hash
    #
    # @example
    #   Spot::Iso6391.all.first.to_h
    #   # => {'aa' => 'Afar'}
    #
    # @return [Array<Hash<String => String>>]
    def self.all
      @all ||= ISO_639::ISO_639_1.select { |e| e.alpha2.present? }.map { |e| [e.alpha2, label_for(e.alpha2)] }.to_h
    end

    # Wrapper method for fetching a label
    #
    # @example
    #   Spot::Iso6391.label_for('en')
    #   # => 'English'
    #
    # @return [String]
    def self.label_for(id)
      new(id).label
    end

    # To make life a little easier for indexing, adding simple wrapper behavior that conforms to the
    # pieces of Spot::ContorlledVocabularies::* that are used in the process.
    def initialize(key)
      @key = key.to_s.downcase
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
    def label
      I18n.t(@key, scope: ['iso_639_1'], default: [ISO_639.find(@key)&.english_name, @key])
    end

    # @see {Spot::RemoteLabelIndexing}
    alias preferred_label label
  end
end
