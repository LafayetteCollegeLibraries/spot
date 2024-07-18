# frozen_string_literal: true
#
# ChangeSet for StudentWorkResource objects. Valkyrie ChangeSets are responsible
# for modifying and validating metadata changes before syncing to the object.
#
# @example
#   work = StudentWorkResource.new
#   change_set = StudentWorkResourceChangeSet.for(work)
#   change_set.title = ['Excellent Work']
#   change_set.sync
#   work.title #=> ['Excellent Work']
#
# @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/models/hyrax/resource.rb
# @see https://github.com/samvera/valkyrie/blob/main/lib/valkyrie/change_set.rb
class StudentWorkResourceChangeSet < ApplicationResourceChangeSet
  property :creator, required: true
  property :advisor, required: true
  property :academic_department, required: true
  property :description, required: true
  property :date, required: true
  property :date_available, required: true
  property :rights_holder, required: true

  property :division
  property :abstract
  property :language
  property :related_resource
  property :organization
  property :subject
  property :keyword
  property :bibliographic_citation
  property :standard_identifier
  property :access_note
  property :note
end