# frozen_string_literal: true
module Hyrax
  class StudentWorksController < ApplicationController
    include Spot::WorksControllerBehavior

    self.curation_concern_type = ::StudentWork
    self.show_presenter = Hyrax::StudentWorkPresenter

    # Modifying the search_builder_class to our subclass which allows
    # users within a work's #read_users collection to view a work that
    # is currently in the middle of a deposit workflow.
    #
    # We were encountering an issue where an advisor on a work would
    # request changes from the Review form, which would send them into
    # a redirection loop with the CAS server. From the best I could deduce,
    # this is being caused by:
    #   - advisor user advancing the workflow to a new step where they
    #     have no active role (see `Hyrax::FilteredSuppressedWithRoles#user_has_active_workflow_role?`
    #     which performs a permission query)
    #   - this causes the controller's search_builder to exclude it from
    #     results (by setting an fq value of "-suppressed_bsi:true")
    #   - because the work is `#suppressed?` and the user can :read the
    #     work, they're thrown a WorkflowAuthorizationException...
    #   - ... which is rescued and served as :not_authorized
    #   - devise_cas_authenticatable (via rack-cas internals) then intercepts
    #     the :not_authorized (401) response and then falls into a redirection
    #     loop with the CAS server.
    #
    # A good fix seems to be to modify `#render_unavailable` to render with a
    # status of :forbidden (403), which seems like the most technically sound
    # solution, as 401 Unauthorized indicates that the user has not been authenticated yet,
    # whereas 403 Forbiden indicates that the user explicitly is not allowed to
    # access the request subject). But we want users assigned read_user access
    # to be able to view the work as it's in progress, rather than bouncing them
    # after completing their role in the workflow action. So instead, I'm modifying
    # the search_builder to allow read_users access in cases where their workflow
    # role may not.
    #
    # @see {Spot::StudentWorkSearchBuilder}
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/search_builders/hyrax/filter_suppressed_with_roles.rb#L26-L31
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/controllers/concerns/hyrax/works_controller_behavior.rb#L210-L251
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/controllers/concerns/hyrax/works_controller_behavior.rb#L225
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/controllers/concerns/hyrax/works_controller_behavior.rb#L229-L251
    # @see https://github.com/biola/rack-cas#integration
    # @todo Are there other instances of Hyrax sending :not_authorized when :forbidden would be preferable?
    self.search_builder_class = ::Spot::StudentWorkSearchBuilder
  end
end
