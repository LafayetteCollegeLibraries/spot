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

    # Called at the end of #initialize. We're using this to add some defaults for student users
    # when the work is created:
    #
    #   - creator
    #     - user's name, authority style ("Lastname, Firstname")
    #   - rights_statement
    #     - In Copyright, Educational Use Permitted (via DEFAULT_RIGHTS_STATEMENT_URI constant)
    #   - rights_holder
    #     - user's name, authority style
    def initialize_fields
      super

      return unless current_user.student? && model.new_record?

      # not sure if the #blank? checks are necessary, since we're already checking model#new_record?
      # but juuust in case...
      self[:creator] = [current_user.authority_name] if self[:creator].all?(&:blank?)
      self[:rights_statement] = DEFAULT_RIGHTS_STATEMENT_URI if self[:rights_statement].blank?
      self[:rights_holder] = [current_user.authority_name] if self[:rights_holder].all?(&:blank?)
    end
  end
end
