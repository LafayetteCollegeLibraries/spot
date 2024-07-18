class StudentWorkResource < ::Hyrax::Work
  include Hyrax::Schema(:base_metadata)
  include Hyrax::Schema(:institutional_metadata)
  include Hyrax::Schema(:student_work_metadata)
end