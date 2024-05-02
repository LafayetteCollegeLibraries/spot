# frozen_string_literal: true
module Spot
  # Service to handle the parsing of CAS entitlements (in the form of URIs) and mapping
  # those values to `Role`s that can be assigned to a User. This will retain roles for a
  # User that do not directly relate to the CAS entitlements (these are assigned in the UI)
  #
  # @example
  #   entitlements = ['https://ldr.lafayette.edu/faculty', 'https://ldr.lafayette.edu/staff']
  #   user = User.find_by(email: 'malantoa@lafayette.edu')
  #   user.roles
  #   # => #<ActiveRecord::Associations::CollectionProxy [#<Role id: 1, name: "admin">]>]
  #   Spot::CasUserRolesService.update_roles_from_entitlements(user: user, entitlements: entitlements)
  #   # => [#<Role id: 1, name: "admin">, #<Role id: 4, name: "faculty">, #<Role id: 5, name: "staff">]
  #   user.roles
  #   # => #<ActiveRecord::Associations::CollectionProxy [#<Role id: 1, name: "admin">, #<Role id: 4, name: "faculty">, #<Role id: 5, name: "staff">]>
  #   user.save
  class CasUserRolesService
    # URI host for valid entitlements
    class_attribute :entitlement_host, default: 'ldr.lafayette.edu'

    # Roles/Groups that we handle via CAS attributes
    class_attribute :group_names_from_cas, default: [
      Ability.alumni_group_name,
      Ability.faculty_group_name,
      Ability.staff_group_name,
      Ability.student_group_name
    ].freeze

    attr_reader :user

    # @param [Hash] options
    # @option [User] user
    # @option [Array<String>] entitlements
    def self.update_roles_from_entitlements(user:, entitlements:)
      new(user: user).update_roles_from_entitlements(entitlements)
    end

    # @param [Hash] options
    # @option [User] user
    def initialize(user:)
      @user = user
    end

    # Parses an array of entitlements (in the form of URIs) into User Roles
    # and attaches them to the `user` account. Retains Roles assigned in the
    # UI (such as "admin" and "depositor"), but will remove roles that are
    # no longer applicable.
    #
    # @param [Array<String>] entitlements
    # @return [void]
    def update_roles_from_entitlements(entitlements)
      role_names = user.roles.map(&:name)
      reset_roles = role_names - group_names_from_cas
      entitlement_roles = entitlements.map { |v| role_name_from_entitlement(v) }.compact.uniq
      rehydrated_roles = (reset_roles + entitlement_roles).map { |name| Role.find_or_create_by(name: name) }
      user.roles = rehydrated_roles
    end

    private

    # Parses a role/group name from an entitlement URI.
    #
    # @param [String] value
    # @return [String]
    def role_name_from_entitlement(value)
      parsed = URI.parse(value)
      return unless parsed.host == entitlement_host

      case parsed.path
      when '/alumni'  then Ability.alumni_group_name
      when '/faculty' then Ability.faculty_group_name
      when '/staff'   then Ability.staff_group_name
      when '/student' then Ability.student_group_name
      end
    end
  end
end
