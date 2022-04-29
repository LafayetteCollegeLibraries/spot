# frozen_string_literal: true
module Hyrax
  class StudentWorksController < ApplicationController
    include Spot::WorksControllerBehavior

    self.curation_concern_type = ::StudentWork
    self.show_presenter = Hyrax::StudentWorkPresenter

    # Modifying the search_builder_class to allow users whose user_keys
    # are stored as a StudentWork#advisor value to view works currently
    # in a workflow, that would normally be suppressed. We were finding
    # that when an advisor submitted a request for changes to a work,
    # their ability to view the work was recinded, as their "advising"
    # workflow role wasn't eligible at the next stage. This would (for
    # some reason) kick the user to CAS to re-authenticate, redirect them
    # back to the :unauthorized work page, and then spiral into a redirect loop.
    #
    # This comes into play at Hyrax::WorksControllerBehavior#search_result_document,
    # which uses Blacklight results to find the first valid document.
    # With the default search_builder (Hyrax::WorkSearchBuilder), the
    # work would not be returned after the advisor fell out of scope
    # in the workflow. Our custom StudentWorkSearchBuilder checks a work's
    # "advisor_ssim" field for the current_user to determine whether the
    # "suppressed?" flag should be enabled or disabled.
    #
    # I don't fully understand the reasoning behind raising a WorkflowAuthorizationException
    # if a doc is suppressed but the current_user has :read access to it
    # (see Hyrax::WorksControllerBehavior#document_not_found!), but in order to
    # avoid that being thrown, we need to have search_result_document return the
    # document for valid users.
    #
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/controllers/concerns/hyrax/works_controller_behavior.rb#L216-L221
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/controllers/concerns/hyrax/works_controller_behavior.rb#L223-L227
    self.search_builder_class = ::Spot::StudentWorkSearchBuilder
  end
end
