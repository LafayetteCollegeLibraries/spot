# frozen_string_literal: true
class AudioVisualResource < BaseResource
  include Hyrax::Schema(:audio_visual_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  def identifier
    attributes[:identifier].map { |v| v.is_a?(String) ? Spot::Identifier.from_string(v) : v }
  end

  def local_identifier
    identifier.select(&:local?)
  end

  def standard_identifier
    identifier.select(&:standard?)
  end

  attribute :stored_derivatives, Valkyrie::Types::String
end
