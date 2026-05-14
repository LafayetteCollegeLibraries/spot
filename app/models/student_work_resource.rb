# frozen_string_literal: true
class StudentWorkResource < ::Hyrax::Work
  include Hyrax::Schema(:base_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:institutional_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:student_work_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  Hyrax::ValkyrieLazyMigration.migrating(self, from: ::StudentWork)
end
