# frozen_string_literal: true
module Spot
  class StudentWorkSearchBuilder < ::Hyrax::WorkSearchBuilder
    # Modified from Hyrax::FilteredSuppressedWithRoles search_builder method to
    # allow users specified in the StudentWork#advisor property to be able to view
    # the work while it's currently in the workflow process.
    #
    # Also moves `#user_has_active_workflow_role?` method to after checking `#depositor?`
    # and `#advisor?`, as those methods don't require database lookups.
    #
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/search_builders/hyrax/filter_suppressed.rb#L10-L13
    def only_active_works(solr_parameters)
      return if depositor? || advisor? || user_has_active_workflow_role?

      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-suppressed_bsi:true'
    end

    private

    # Is the user_key (email) of the currently logged in user found in the work's "advisor_ssim" field?
    #
    # @return [true, false]
    def advisor?
      user_key = current_ability&.current_user&.user_key
      return false unless user_key && current_work['advisor_ssim'].present?

      current_work.fetch('advisor_ssim', []).any? { |advisor| advisor == user_key }
    end
  end
end
