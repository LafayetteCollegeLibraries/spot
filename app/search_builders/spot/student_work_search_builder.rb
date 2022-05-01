# frozen_string_literal: true
module Spot
  class StudentWorkSearchBuilder < ::Hyrax::WorkSearchBuilder
    # Modified from Hyrax::FilteredSuppressedWithRoles search_builder method
    # to allow users specified in a StudentWork's read_users to view an item,
    # even if they do not currently have an active workflow role.
    #
    # As part of the mediated_student_work_deposit workflow, we're granting
    # read access to users listed in the #advisor field, and want that access
    # to be prioritized over the user having an active workflow role, which
    # I believe was causing a redirection loop to occur.
    #
    # @todo If we're planning on using workflows for other work types, we might
    #       want/need to rename this to a generic SearchBuilder and attach it
    #       in {Spot::WorksControllerBehavior}
    #
    # @see {Hyrax::StudentWorksController}
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/services/hyrax/workflow/permission_query.rb#L35-L58
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/search_builders/hyrax/filter_suppressed_with_roles.rb#L26-L31
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/search_builders/hyrax/filter_suppressed.rb#L10-L13
    def only_active_works(solr_parameters)
      # this feels better than calling them all within an OR conditional?
      return if %i[depositor? read_user? admin? user_has_active_workflow_role?].any? { |m| send(m) }

      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-suppressed_bsi:true'
    end

    private

    def admin?
      current_ability&.admin?
    end

    def read_user?
      user_key = current_ability&.current_user&.user_key
      return false unless user_key && current_work[solr_field].present?

      current_work.fetch(solr_field, []).any? { |person| person == user_key }
    end

    def solr_field
      'read_access_person_ssim'
    end
  end
end
