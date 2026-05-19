# frozen_string_literal: true
class StudentWorkResourceForm < Hyrax::Forms::ResourceForm(StudentWorkResource)
  include Hyrax::FormFields(:core_metadata)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:Student_work_metadata)
  include Hyrax::FormFields(:institutional_metadata)
end
