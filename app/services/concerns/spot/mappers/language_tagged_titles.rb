# frozen_string_literal: true
module Spot::Mappers
  module LanguageTaggedTitles
    extend ActiveSupport::Concern

    included do
      class_attribute :primary_title_map, :title_alternative_map
      self.primary_title_map = { 'title.english' => 'en' }
      self.title_alternative_map = {
        'title.chinese' => 'zh',
        'title.french' => 'fr',
        'title.german' => 'de',
        'title.japanese' => 'ja',
        'title.korean' => 'ko'
      }
    end

    # @return [Array<Symbol>]
    def field
      super + [:title, :title_alternative]
    end

    # @return [Array<RDF::Literal>]
    def title
      key = primary_title_map.keys.first
      language = primary_title_map[key]

      Array.wrap(metadata.fetch(key, []))
           .reject(&:blank?)
           .map { |val| RDF::Literal(val, language: language.to_sym) }
    end

    # @return [Array<RDF::Literal>]
    def title_alternative
      title_alternative_map.keys.map do |field|
        language = title_alternative_map[field].to_sym
        metadata.fetch(field, []).reject(&:blank?).map do |value|
          RDF::Literal(value, language: language)
        end
      end.flatten
    end
  end
end
