# frozen_string_literal: true

module Spot::Mappers
  class HashMapper < ::Darlingtonia::HashMapper
    class_attribute :fields_map
    self.fields_map = {}

    def fields
      self.fields_map.keys
    end

    # @param [String, Symbol] name The field name
    # @return [any]
    def map_field(name)
      field_name = fields_map[name.to_sym]
      return nil unless field_name

      metadata[field_name]
    end

    def representative_file
      metadata[:representative_files]
    end
  end
end
