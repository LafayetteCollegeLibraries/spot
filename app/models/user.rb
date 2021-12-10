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

  # Can this user deposit items?
  #
  # @return [true, false]
  def depositor?
    roles.where(name: [Ability.admin_group_name, Ability.depositor_group_name]).exists?
  end

  def faculty?
    roles.where(name: Ability.faculty_group_name).exists?
  end

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

  # Sets up attributes returned from CAS. No need to save the object: that's done
  # via devise_cas_authenticatable.
  #
  # @param [Hash<String => String>] attributes
  # @return [void]
  # @todo when/if released, capture: memberOf, affiliation, department
  def cas_extra_attributes=(attributes)
    self.username = attributes['uid']
    self.email = attributes['email']
    self.display_name = "#{attributes['givenName']} #{attributes['surname']}".strip
    self.lnumber = attributes['lnumber']
    self.roles = collect_roles(attributes: attributes)
  end

  private

  def collect_roles(attributes:)
    role_names = attributes.fetch('eduPersonEntitlement', []).map do |value|
      parsed = URI.parse(value)
      next unless parsed.host == 'ldr.lafayette.edu' # @todo should we make this configurable?

      case parsed.path
      when '/faculty'
        Ability.faculty_group_name
      when '/staff'
        Ability.staff_group_name
      when '/student'
        Ability.student_group_name
      end
    end.compact.uniq

    role_names.map { |name| Role.find_or_create_by(name: name) }
  end

  # Callback to ensure that we store a username, as that's what's used for uniqueness.
  # We occasionally provide a depositor in some ingest cases, but that relies on the
  # email address and _not_ the username. We'll capture the username as anything
  # before the +@+ symbol of the email.
  #
  # @return [void]
  def ensure_username
    return unless username.blank?

    self.username = email.gsub(/@.*$/, '')
  end
end
