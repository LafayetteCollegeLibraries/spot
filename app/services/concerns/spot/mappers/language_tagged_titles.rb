# frozen_string_literal: true
module Spot::Mappers
  # Mixin to add methods for extracting language-tagged literal values for
  # +title+ and +title_alternative+ fields. To use, include this mixin and
  # add the +:title+ and +:title_alternative+ symbols to your +#fields+ array.
  #
  # @example
  #   module Spot::Mappers
  #     class AlsaceImagesMapper < BaseMapper
  #       include LanguageTaggedTitles
  #
  #       def fields
  #         super + [:title, :title_alternative]
  #       end
  #     end
  #   end
  #
  # Customization is available through two class attributes: +:primary_title_map+
  # and +:title_alternative_map+. The former is expected to consist of a single
  # key/value pair (where the key is the metadata field to target and the value
  # is a two character symbol representing the language to tag the literal).
  # +:title_alternative_map+ can consist of however many alt-title fields as
  # is necessary. These have been defined at the outset to capture most of our
  # individual collections' variations on titles. It will not raise an exception
  # if a field does not exist in the metadata, meaning you shouldn't have to update
  # the +:title_alternative_map+ if a collection only uses some of the fields
  # provided.
  #
  # @example customizing mappings
  #   module Spot::Mappers
  #     class PostcardCollection < BaseMapper
  #       include LanguageTaggedTitles
  #
  #       self.primary_title_map = { 'title' => :en }
  #       self.title_alternative_map = {
  #         'japanese_title' => :ja,
  #         'korean_title' => :ko
  #       }
  #
  #       def fields
  #         super + [:title, :title_alternative]
  #       end
  #     end
  #   end
  #
  module LanguageTaggedTitles
    extend ActiveSupport::Concern

    included do
      class_attribute :primary_title_map, :title_alternative_map
      self.primary_title_map = { 'title.english' => :en }
      self.title_alternative_map = {
        'title.chinese' => :zh,
        'title.french' => :fr,
        'title.german' => :de,
        'title.japanese' => :ja,
        'title.korean' => :ko
      }
    end

    # @return [Array<RDF::Literal>]
    def title
      field = primary_title_map.keys.first
      language = primary_title_map[field]

      field_to_tagged_literals(field, language)
    end

    # @return [Array<RDF::Literal>]
    def title_alternative
      title_alternative_map.keys.map do |field|
        language = title_alternative_map[field].to_sym
        field_to_tagged_literals(field, language)
      end.flatten
    end

    private

      # Maps a field's values to RDF::Literals tagged with a language
      #
      # @param [String] field
      #   Metadata field to target
      # @param [String, Symbol] language
      #   2 character language code (ex. :en)
      def field_to_tagged_literals(field, language)
        Array.wrap(metadata.fetch(field, []))
             .reject(&:blank?)
             .map { |v| RDF::Literal(v, language: language.respond_to?(:to_sym) ? language.to_sym : language) }
      end
  end
end
