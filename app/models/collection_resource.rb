# frozen_string_literal: true
class CollectionResource < Hyrax::PcdmCollection
  include Hyrax::Schema(:core_metadata)

  attribute :internal_resource, Valkyrie::Types::Any.default('Collection'), internal: true
end
