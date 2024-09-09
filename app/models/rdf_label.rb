# frozen_string_literal: true
#
# An ActiveRecord class to store RDF URIs and their preferred labels
# to save ourselves the hassle of fetching labels every index.
class RdfLabel < ApplicationRecord
  def self.destroy_by(**find_args)
    find_by(**find_args)&.destroy
  end

  def self.label_for(uri:)
    find_by(uri: uri)&.value
  end
end
