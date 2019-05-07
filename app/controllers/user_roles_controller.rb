# frozen_string_literal: true
#
# Expanding the hydra-role-management controller so that
# a user can be added + assigned a role _before_ logging
# in for the first time.
class UserRolesController < ApplicationController
  include Hydra::RoleManagement::UserRolesBehavior

  # Overriding the Hydra::RoleManagement::UserRolesBehavior#create implementation
  # to allow users to be created if they don't exist.
  def create
    authorize! :add_user, @role
    user = ::User.find_or_initialize_by(find_column => params[:user_key])

    flash_message =
      if user.new_record?
        I18n.t('roles.edit.user_created_added_to_role', user: params[:user_key], role: @role.name)
      else
        I18n.t('roles.edit.user_added_to_role', user: params[:user_key], role: @role.name)
      end

    user.roles << @role
    user.save!
    redirect_to role_management.role_path(@role), flash: { user: flash_message }
  end
end
