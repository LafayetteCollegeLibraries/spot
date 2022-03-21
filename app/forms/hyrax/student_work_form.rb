# frozen_string_literal: true
module Hyrax
  class StudentWorkForm < ::Spot::Forms::WorkForm
    DEFAULT_RIGHTS_STATEMENT_URI = 'http://rightsstatements.org/vocab/InC-EDU/1.0/'

    singular_form_fields :title, :description, :date, :date_available, :abstract
    transforms_nested_fields_for :academic_department, :division, :language, :advisor

    delegate :current_user, to: :current_ability

    self.model_class = ::StudentWork
    self.required_fields = [
      :title, :creator, :advisor, :academic_department, :description, :date, :resource_type, :rights_statement
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
      :resource_type,
      :rights_statement,
      :rights_holder,

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
        :title, :creator, :advisor, :academic_department, :description,
        :date, :resource_type, :rights_statement, :rights_holder
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
          params[:admin_set_id] = admin_set_id if params[:admin_set_id].blank?
        end
      end

      private

      # use our automatically-created admin_set for student works and
      # fall back to the default set if the student one is gone
      #
      # @return [String]
      def admin_set_id
        Spot::StudentWorkAdminSetCreateService.find_or_create_student_work_admin_set_id
      rescue Ldp::Gone
        AdminSet.find_or_create_default_admin_set_id
      end
    end

    protected

    # Called from within `#initialize_fields` which sets up individual fields for the form.
    # Generally, this is to stuff empty values, but for student users we want to provide
    # some defaults:
    #   - creator
    #     - user's name, authority style ("Lastname, Firstname")
    #   - rights_statement
    #     - In Copyright, Educational Use Permitted (via DEFAULT_RIGHTS_STATEMENT_URI constant)
    #   - rights_holder
    #     - user's name, authority style
    #
    # This is only called for `.terms` values that are `#blank?`, so it's safe to assume
    # that these are empty (no need to further check their `#blank?` status).
    #
    # @param [#to_sym]
    # @return [void]
    # @see https://github.com/samvera/hydra-editor/blob/v5.0.5/app/forms/hydra_editor/form.rb#L102-L109
    def initialize_field(key)
      return super unless current_user.student?

      case key.to_sym
      when :creator
        self[key] = [current_user.authority_name]
      when :rights_statement
        self[key] = DEFAULT_RIGHTS_STATEMENT_URI
      when :rights_holder
        self[key] = [current_user.authority_name]
      else
        super
      end
    end
  end
end
