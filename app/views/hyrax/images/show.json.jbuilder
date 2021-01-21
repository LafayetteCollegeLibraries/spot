# frozen_string_literal: true
#
# Jbuilder template for rendering Image works as JSON. The out-of-the-box template
# from hyrax (see <hyrax-root>/app/views/hyrax/base/show.json.jbuilder) will generate a
# stack depth error for some reason (the logs aren't very helpful) that seems to be related
# to fields with non-standard values (namely wrapped URIs). So our current solution is to
# explicitly declare what fields are returned.
#
# @todo are :note, :donor, and :requested_by admin only?
json.id(@curation_concern.id)

# titles
json.title(@curation_concern.title.map(&:to_s))
json.title_alternative(@curation_concern.title_alternative.map(&:to_s))
json.subtitle(@curation_concern.subtitle.map(&:to_s))

# creators
json.extract!(@curation_concern, :creator, :contributor, :publisher)

# descriptive text
json.resource_type(@curation_concern.resource_type)
json.description(@curation_concern.description.map(&:to_s))
json.inscription(@curation_concern.inscription.map(&:to_s))

# subjects, locations, identifiers
json.subject(map_uris(@curation_concern.subject))
json.keyword(@curation_concern.keyword)
json.location(map_uris(@curation_concern.location))
json.extract!(@curation_concern, :identifier, :source, :language)
json.ocm_classification(@curation_concern.subject_ocm.sort)

# dates
json.extract!(@curation_concern, :date, :date_scope_note, :date_associated, :date_uploaded, :date_modified)

# more descriptions
json.extract!(@curation_concern, :physical_medium, :original_item_extent, :repository_location, :related_resource, :research_assistance)

# rights info
json.rights_statement(map_uris(@curation_concern.rights_statement))
json.rights_holder(@curation_concern.rights_holder)

json.version(@curation_concern.etag)
