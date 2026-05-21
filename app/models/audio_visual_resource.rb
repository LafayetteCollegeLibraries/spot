# frozen_string_literal: true
class AudioVisualResource < BaseResource
  include Hyrax::Schema(:audio_visual_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  attribute :stored_derivatives, Valkyrie::Types::String
end
