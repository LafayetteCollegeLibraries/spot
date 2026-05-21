# frozen_string_literal: true
class StudentWorkResource < BaseResource
  include Hyrax::Schema(:institutional_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:student_work_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
end
