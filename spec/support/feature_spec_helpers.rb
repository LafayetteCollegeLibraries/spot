# frozen_string_literal: true
module FeatureSpecHelpers
  # Ensures that the provided user is able to deposit into the default admin_set
  #
  # @param [User] user
  # @return [Hyrax::PermissionTemplateAccess]
  def ensure_deposit_access_for(user)
    default_admin_set_id = Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id
    permission_template = Hyrax::PermissionTemplate.find_or_create_by!(source_id: default_admin_set_id)

    Hyrax::PermissionTemplateAccess.find_or_create_by!(
      permission_template: permission_template,
      agent_type: 'user',
      agent_id: user.email,
      access: 'deposit'
    )
  end
end
