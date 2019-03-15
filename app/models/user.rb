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

  # Sets up attributes returned from CAS
  #
  # @param [Hash<String => String>] attributes
  # @return [void]
  def cas_extra_attributes=(attributes)
    self.username = attributes['uid']
    self.member_of = attrs['memberOf']

    self.display_name = attributes['givenName']
    self.display_name += " #{attributes['sn']}" if attributes['sn']

    # self.affiliation = attributes['affiliation'] if attributes['affiliation']
    # self.department = attributes['department'] if attributes['department']
  end
end
