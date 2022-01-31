# frozen_string_literal: true
module Spot
  # Service for centralizing where our system users are defined.
  class SystemUserService
    AUDIT_USER_DISPLAY_NAME = 'AuditBot'
    AUDIT_USER_EMAIL = Hyrax.config.audit_user_key
    BATCH_USER_DISPLAY_NAME = 'DeposiBot'
    BATCH_USER_EMAIL = Hyrax.config.batch_user_key

    # Defining class methods this way so that we are able to keep `.find_or_create_system_user` private
    class << self
      # @return [User]
      def audit_user
        find_or_create_system_user(display_name: AUDIT_USER_DISPLAY_NAME, email: AUDIT_USER_EMAIL)
      end

      # @return [User]
      def batch_user
        find_or_create_system_user(display_name: BATCH_USER_DISPLAY_NAME, email: BATCH_USER_EMAIL)
      end

      private

      def find_or_create_system_user(display_name:, email:)
        user = User.find_or_create_by(display_name: display_name, email: email)
        return user if user.admin?

        admin_role = Role.find_or_create_by(name: Ability.admin_group_name)
        admin_role.users << user
        admin_role.save
        user.reload

        user
      end
    end
  end
end
