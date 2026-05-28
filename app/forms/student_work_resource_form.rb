# frozen_string_literal: true
class StudentWorkResourceForm < Hyrax::Forms::ResourceForm(StudentWorkResource)
  include Spot::Forms::BaseResourceFormBehavior

  include Hyrax::FormFields(:core_metadata)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:Student_work_metadata)
  include Hyrax::FormFields(:institutional_metadata)

  nested_attributes_for(:academic_department, :division, :advisor)

  def primary_terms
    [
      :title,
      :creator,
      :advisor,
      :academic_department,
      :description,
      :date,
      :date_available,
      :resource_type,
      :rights_statement,
      :rights_holder
    ]
  end

  def secondary_terms
    [
      :division,
      :abstract,
      :language,
      :related_resource,
      :organization,
      :subject,
      :keyword,
      :bibliographic_citation,
      :standard_identifier,
      :access_note,
      :note
    ]
  end
end
