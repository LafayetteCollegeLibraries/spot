# frozen_string_literal: true
#
# Common fields / behaviors shared across Work types
class BaseResource < Hyrax::Work
  include Spot::HasControlledFields

  include Hyrax::Schema(:core_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:base_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  has_controlled_field :subject, vocabulary_class: Spot::ControlledVocabularies::AssignFastSubject
  has_controlled_field :location, vocabulary_class: Spot::ControlledVocabularies::GeonamesLocation
end
