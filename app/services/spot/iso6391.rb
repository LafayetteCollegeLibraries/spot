# frozen_string_literal: true

# An utility class for the +iso-639+ gem. We're storing the dictionary
# in a class variable so we don't need to load it every time.
module Spot
  class ISO6391
    class << self
      # All of the ISO-639-1 entries in a key/val hash
      #
      # @example
      #   Spot::LanguageAuthority.all.first.to_h
      #   # => {'aa' => 'Afar'}
      #
      # @return [Array<Hash<Symbol => String>>]
      def all
        @all ||= mapped_639_1_entries
      end

      # Find the label for a language by its 2-char entry.
      #
      # @param [String] id
      # @return [String, NilClass]
      def label_for(id)
        all[id.downcase]
      end

      private

        def language_hash
          YAML.load_file(Rails.root.join('config', 'authorities', 'languages.yml'))
        end

        # iso639-1 entries mapped to a key/val hash
        #
        # @return [Hash<String => String>]
        def mapped_639_1_entries
          language_hash['terms'].map { |entry| [entry['id'], entry['term']] }.to_h
        end
    end
  end
end
