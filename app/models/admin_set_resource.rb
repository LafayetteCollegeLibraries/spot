# frozen_string_literal: true
#
# Subclassing our own AdminSetResource model to give a path to modify down the road
class AdminSetResource < Hyrax::AdministrativeSet
  include Hyrax::ArResource
  include Hyrax::Permissions::Readable

  attribute :internal_resource, Valkyrie::Types::Any.default('AdminSet'), internal: true
end
