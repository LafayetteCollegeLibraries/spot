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
  end
end
