# frozen_string_literal: true

module Spot::Mappers
  class BaseHashMapper < ::Darlingtonia::HashMapper
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

    # @return [Array<String>] paths to files of works to be attached
    def representative_files
      metadata[:representative_files]
    end
    alias_method :representative_file, :representative_files
  end
end
