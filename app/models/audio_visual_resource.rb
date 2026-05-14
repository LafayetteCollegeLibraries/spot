# frozen_string_literal: true
class AudioVisualResource < ::Hyrax::Work
  include Hyrax::Schema(:base_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:audio_visual_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  attribute :stored_derivatives, Valkyrie::Types::String

  Hyrax::ValkyrieLazyMigration.migrating(self, from: ::AudioVisual)
end
