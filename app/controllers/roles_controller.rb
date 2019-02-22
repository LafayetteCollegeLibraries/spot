# frozen_string_literal: true
#
# The controller responsible for most of the +hydra-role-management+
# functionality. We're overwriting the gem's controller in order to
# wrap the functionality within the Hyrax dashboard layout and add
# breadcrumbs to it.
class RolesController < ApplicationController
  include Hydra::RoleManagement::RolesBehavior

  before_action :add_common_breadcrumbs

  with_themed_layout 'dashboard'

  # Overwriting the original #edit method in order to redirect users
  # without the edit ability to the #show page
  def edit
    redirect_to role_management.role_path(@role) unless can? :edit, @role
  end

  private

    # @return [void]
    def add_common_breadcrumbs
      add_breadcrumb t('hyrax.controls.home'), root_path
      add_breadcrumb t('hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t('role-management.breadcrumb'), role_management.roles_path
    end
end
