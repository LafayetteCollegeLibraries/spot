# frozen_string_literal: true
#
# The model for our Users. As of now, this is just the stock items that are
# included when running +rails generate hyrax:install+ (which also runs installs
# for hydra and blacklight)
class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  devise :cas_authenticatable, :rememberable

  before_save :ensure_username

  # Does this user belong to the Alumni group?
  #
  # @return [true, false]
  def alumni?
    roles.where(name: Ability.alumni_group_name).exists?
  end

  # Can this user deposit items?
  #
  # @return [true, false]
  def depositor?
    roles.where(name: [Ability.admin_group_name, Ability.depositor_group_name]).exists?
  end

  # Does this user belong to the Faculty group?
  #
  # @return [true, false]
  def faculty?
    roles.where(name: Ability.faculty_group_name).exists?
  end

  # Does this user belong to the Staff group?
  #
  # @return [true, false]
  def staff?
    roles.where(name: Ability.staff_group_name).exists?
  end

  # Does this user belong to the Student group?
  #
  # @return [true, false]
  def student?
    roles.where(name: Ability.student_group_name).exists?
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  #
  # @return [String]
  def to_s
    email
  end

  # Name rendered in an authoritative "Surname, Given-Name" style
  #
  # @return [String]
  def authority_name
    [surname, given_name].compact.join(', ')
  end

  # Name rendered in a "Given-Name Surname" style
  #
  # @return [String]
  def display_name
    "#{given_name} #{surname}".strip
  end

  # Sets up attributes returned from CAS. No need to save the object: that's done
  # via devise_cas_authenticatable.
  #
  # @param [Hash<String => String>] attributes
  # @return [void]
  def cas_extra_attributes=(attributes)
    self.username = attributes['uid']
    self.email = attributes['email']
    self.given_name = attributes['givenName']
    self.surname = attributes['surname']
    self.lnumber = attributes['lnumber']

    update_roles_from_attributes(attributes)
  end

  private

  # Delegates the updating of User Roles to `Spot::CasUserRolesService`, which will
  # retain roles assigned outside of CAS.
  #
  # @param [Hash<String => String>] attributes
  # @return [void]
  def update_roles_from_attributes(attributes)
    entitlements = Array.wrap(attributes.fetch('eduPersonEntitlement', []))
    Spot::CasUserRolesService.update_roles_from_entitlements(user: self, entitlements: entitlements)
  end

  # Callback to ensure that we store a username, as that's what's used for uniqueness.
  # We occasionally provide a depositor in some ingest cases, but that relies on the
  # email address and _not_ the username. We'll capture the username as anything
  # before the +@+ symbol of the email.
  #
  # @return [void]
  def ensure_username
    return if username.present?

    self.username = email.gsub(/@.*$/, '')
  end
end
