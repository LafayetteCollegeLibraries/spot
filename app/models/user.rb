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

  enum affiliation: {
    unknown: 0,
    student: 1,
    faculty: 2,
    staff: 3,
    alumni: 4
  }, _suffix: true

  # Can this user deposit items?
  #
  # @return [true, false]
  def depositor?
    roles.where(name: [Ability.admin_group_name, 'depositor']).exists?
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
    self.affiliation = affiliation_from_attributes(attributes)
  end

  private

    # Determines the value for `affiliation` from the passed attributes.
    #
    # @return [Symbol]
    def affiliation_from_attributes(attributes)
      entitlement = URI.parse(attributes.fetch('eduPersonEntitlement', ''))
      return :unknown unless entitlement.host == 'ldr.lafayette.edu'

      case entitlement.path
      when '/student', '/faculty', '/staff', '/alumni'
        entitlement.path[1..-1].to_sym
      else
        :unknown
      end
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
