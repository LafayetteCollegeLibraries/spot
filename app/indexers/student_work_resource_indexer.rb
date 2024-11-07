# frozen_string_literal: true
class StudentWorkResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:institutional_metadata)
  include Hyrax::Indexer(:student_work_metadata)

  self.sortable_date_property = :date
end
