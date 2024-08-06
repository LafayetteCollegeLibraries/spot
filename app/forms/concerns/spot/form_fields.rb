# frozen_string_literal: true
module Spot
  # Form Field definitions
  #  @example
  #  attributes:
  #    title:
  #      form:
  #        primary: false
  #        required: true
  #        nested_attributes:
  #          value_key: id
  #          value_type: uri
  #
  #
  def self.FormFields(schema_name, **options)
    Spot::FormFields.new(schema_name, **options)
  end

  class FormFields < ::Hyrax::FormFields
    private

    def included(descendant)
      super

      form_field_definitions.each do |field_name, options|

      end
    end
  end
end