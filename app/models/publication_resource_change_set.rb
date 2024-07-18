# frozen_string_literal: true
#
# ChangeSet for PublicationResource objects. Valkyrie ChangeSets are responsible
# for modifying and validating metadata changes before syncing to the object.
#
# @example
#   work = PublicationResource.new
#   change_set = PublicationResourceChangeSet.for(work)
#   change_set.title = ['Excellent Work']
#   change_set.sync
#   work.title #=> ['Excellent Work']
#
# @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/models/hyrax/resource.rb
# @see https://github.com/samvera/valkyrie/blob/main/lib/valkyrie/change_set.rb
class PublicationResourceChangeSet < ApplicationResourceChangeSet
  validates_with Spot::EdtfDateValidator, fields: [:date_issued]

  property :date_issued, required: true

  property :rights_holder
  property :subtitle
  property :title_alternative
  property :creator
  property :contributor
  property :editor
  property :publisher
  property :source
  property :bibliographic_citation
  property :standard_identifier
  property :local_identifier
  property :abstract
  property :description
  property :subject
  property :keyword
  property :language
  property :physical_medium
  property :location
  property :note
  property :related_resource
  property :academic_department
  property :division
  property :organization
end