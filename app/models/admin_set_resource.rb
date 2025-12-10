# frozen_string_literal: true
#
# @see https://github.com/samvera/hyrax/blob/hyrax-v5.2.0/.dassie/app/models/admin_set_resource.rb
class AdminSetResource < Hyrax::AdministrativeSet
  include Hyrax::ArResource
  include Hyrax::Permissions::Readable
end
