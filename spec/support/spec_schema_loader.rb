# frozen_string_literal: true
class SpecSchemaLoader < Hyrax::SimpleSchemaLoader
  # How else can we check if an attribute field is an URI?
  #
  # @param [Hash] options
  # @option [Symbol] schema
  # @return [Hash<Symbol, Hash<String, *>>]
  def raw_attributes_for(schema:)
    schema_config(schema)['attributes'].symbolize_keys
  end
end