# frozen_string_literal: true
class PublicationResourceForm < Hyrax::Forms::ResourceForm(PublicationResource)
  include Spot::Forms::BaseResourceFormBehavior

  include Hyrax::FormFields(:publication_metadata)
  include Hyrax::FormFields(:institutional_metadata)

  nested_attributes_for(:academic_department, :division)

  def primary_terms # rubocop:disable Metrics/MethodLength
    [
      :title,
      :date_issued,
      :resource_type,
      :rights_statement,

      # starting with rights holder since it relates to rights_statement
      :rights_holder,
      :subtitle,
      :title_alternative,
      :creator,
      :contributor,
      :editor,
      :publisher,
      :source,
      :bibliographic_citation,
      :standard_identifier,
      :local_identifier,
      :abstract,
      :description,
      :subject,
      :keyword,
      :language,
      :physical_medium,
      :location,
      :related_resource,
      :academic_department,
      :division,
      :organization,
      :note
    ]
  end
end
