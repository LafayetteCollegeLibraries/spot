# frozen_string_literal: true
module Hyrax
  class StudentWorkForm < ::Spot::Forms::WorkForm
    singular_form_fields :title, :description, :date, :date_available, :abstract
    transforms_nested_fields_for :academic_department, :division, :language, :advisor

    self.model_class = ::StudentWork
    self.required_fields = [
      :title, :creator, :advisor, :academic_department, :division,
      :description, :date, :date_available, :rights_statement, :resource_type
    ]

    self.terms = [
      # required
      :title,
      :creator,
      :advisor,
      :academic_department,
      :division,
      :description,
      :date,
      :date_available,
      :rights_statement,
      :resource_type,

      # below the fold
      :abstract,
      :language,
      :related_resource,
      :access_note,

      # librarian-added fields, applied during review
      :organization,
      :subject,
      :keyword,
      :bibliographic_citation,
      :standard_identifier,
      :note
    ].concat(hyrax_form_fields)

    def primary_terms
      [
        :title, :creator, :advisor, :academic_department, :division, :description,
        :date, :date_available, :rights_statement, :resource_type
      ]
    end

    class << self
      def build_permitted_params
        super.tap do |params|
          params << { subject_attributes: [:id, :_destroy] }
        end
      end

      # We aren't rendering the "relationships" tab for non-admin users, so when the form
      # is submitted, it should be missing the "admin_set_id" param, which we'll stuff with
      # the AdminSet that is utilizing the "mediated_student_work_deposit" workflow
      def model_attributes(_form_params)
        super.tap do |params|
          params[:admin_set_id] = workflow_admin_set_id if params[:admin_set_id].blank?
        end
      end

      private

      def workflow_admin_set_id
        workflow = Sipity::Workflow.where(name: 'mediated_student_work_deposit').order(updated_at: :desc).first
        return AdminSet::find_or_create_default_admin_set_id if workflow.nil?

        workflow.permission_template.admin_set.id
      end
    end
  end
end
