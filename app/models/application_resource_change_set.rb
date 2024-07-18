# frozen_string_literal: true
#
# Abstract ChangeSet base for resources.
class ApplicationResourceChangeSet < ::Hyrax::ChangeSet
  property :title, multiple: false, required: true
  property :resource_type, required: true
  property :rights_statement, multiple: false, required: true

  validates :title, presence: { message: 'Your work must include a Title' }, if: :validate_title?
  validates :resource_type, presence: { message: 'Your work must include a Resource Type.' }, if: :validate_resource_type?
  validates :rights_statement, presence: { message: 'Your work must include a Rights Statement.' }, if: :validate_rights_statement?

  validates_with ::Spot::RequiredLocalAuthorityValidator,
                 field: :resource_type, authority: 'resource_types', if: :validate_resource_type?
  validates_with ::Spot::RequiredLocalAuthorityValidator,
                 field: :rights_statement, authority: 'rights_statements', if: :validate_rights_statement?

  # To disable validation on default fields, redefine the appropriate checks in your subclass.
  def validate_title?
    true
  end

  def validate_resource_type?
    true
  end

  def validate_rights_statement?
    true
  end
end
