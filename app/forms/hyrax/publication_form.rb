# frozen_string_literal: true

module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    self.model_class = Publication
    self.terms = [
      # titles
      :title,
      :subtitle,
      :title_alternative,

      # provenance
      :creator,
      :contributor,
      :editor,
      :publisher,
      :source,
      :academic_department,
      :division,
      :organization,

      # description
      :abstract,
      :description,
      :date_issued,
      :date_available,
      :resource_type,
      :physical_medium,
      :language,
      :subject,
      :keyword,
      :based_near,
      :bibliographic_citation,
      :identifier,
      :related_resource,
    ]

    def self.model_attributes(form_params)
      prefixes = form_params.delete('identifier_prefix')
      values = form_params.delete('identifier_value')

      merged = prefixes.zip(values).map do |(key, value)|
        Spot::Identifier.new(key, value).to_s
      end

      super.tap do |params|
        params[:identifier] = merged
      end
    end

    def self.build_permitted_params
      super.tap do |params|
        params << { identifier_prefix: [] }
        params << { identifier_value: [] }
      end
    end
  end
end
