# frozen_string_literal: true
class CollectionResource < Hyrax::PcdmCollection
  include Hyrax::Schema(:core_metadata)

  Hyrax::ValkyrieLazyMigration.migrating(self, from: ::Collection)
end
