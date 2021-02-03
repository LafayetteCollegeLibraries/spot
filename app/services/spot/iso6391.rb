# frozen_string_literal: true
module Spot
  # Helper module for ISO-639 language code -> english-name conversion. Essentially a wrapper
  # around the +iso-639+ gem, with the ability to provide overrides for some language labels.
  #
  # @example Getting the English label for a language from the iso-639 gem
  #   Spot::ISO6391.label_for('en')
  #   # => "English"
  #
  # @example Getting the English label for a language that uses a local override
  #   Spot::ISO6391::OVERRIDES
  #   # => { 'es' => 'Spanish' }
  #   ISO_639.find('es').english_name
  #   # => "Spanish; Castilian"
  #   Spot::ISO6391.label_for('es')
  #   # => "Spanish"
  module ISO6391
    # Local overrides for labels. Allows us to add preferred labels for values
    # instead of relying on the +iso-639+ gem labels.
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

    # Find the label for a language by its 2-char entry. Tries our local overrides hash first
    # falling back to the +iso-639+ gem label.
    #
    # @param [String] id
    # @return [String, NilClass]
    def self.label_for(id)
      id = id.to_s.downcase
      OVERRIDES[id] || all[id]
    end
  end
end
