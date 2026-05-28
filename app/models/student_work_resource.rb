# frozen_string_literal: true
class StudentWorkResource < BaseResource
  include Hyrax::Schema(:institutional_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:student_work_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

    def identifier
    attributes[:identifier].map { |v| v.is_a?(String) ? Spot::Identifier.from_string(v) : v }
  end

  def standard_identifier
    identifier.select(&:standard?)
  end
end
