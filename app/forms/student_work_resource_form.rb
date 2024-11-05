# frozen_string_literal: true
# Form to edit StudentWorkResource objects
#
# @todo In StudentWorkForm we default :creator and :rights_holder to the name
#       of the depositing user, but I don't think we have a hook in the form.
#       This might need to be added at the controller level.
class StudentWorkResourceForm < ::Hyrax::Forms::ResourceForm(StudentWorkResource)
  DEFAULT_RIGHTS_STATEMENT_URI = 'http://rightsstatements.org/vocab/InC-EDU/1.0/'

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:institutional_metadata)
  include Hyrax::FormFields(:student_work_metadata)

  include Spot::NestedAttributeFormFields(:subject, :language, :academic_department, :advisor, :division)

  validates_with Spot::EdtfDateValidator, fields: [:date]

  # @todo provide the StudentWork admin_set as a default? Or stuff the value and not expose it?
  def admin_set_id
  end

  def rights_statement
    super || [DEFAULT_RIGHTS_STATEMENT_URI]
  end
end

