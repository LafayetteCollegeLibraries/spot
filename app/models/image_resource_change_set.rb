# frozen_string_literal: true
#
# ChangeSet for ImageResource objects. Valkyrie ChangeSets are responsible
# for modifying and validating metadata changes before syncing to the object.
#
# @example
#   work = ImageResource.new
#   change_set = ImageResourceChangeSet.for(work)
#   change_set.title = ['Excellent Work']
#   change_set.sync
#   work.title #=> ['Excellent Work']
#
# @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/models/hyrax/resource.rb
# @see https://github.com/samvera/valkyrie/blob/main/lib/valkyrie/change_set.rb
class ImageResourceChangeSet < ::Hyrax::ChangeSet
  validates_with Spot::EdtfDateValidator, fields: [:date, :date_associated]
  validates_with Spot::RequiredLocalAuthorityValidator, field: :subject_ocm, authority: 'subject_ocm'

  property :date
  property :title_alternative
  property :subtitle
  property :date_associated
  property :date_scope_note
  property :rights_holder
  property :description
  property :inscription
  property :creator
  property :contributor
  property :publisher
  property :keyword
  property :subject
  property :location
  property :language
  property :source
  property :physical_medium
  property :original_item_extent
  property :repository_location
  property :requested_by
  property :research_assistance
  property :donor
  property :related_resource
  property :local_identifier
  property :subject_ocm
  property :note
end