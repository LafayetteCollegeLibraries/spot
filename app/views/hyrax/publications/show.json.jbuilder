# Jbuilder template for rendering Publication works as JSON. The out-of-the-box template
# from hyrax (see <hyrax-root>/app/views/hyrax/base/show.json.jbuilder) will generate a
# stack depth error for some reason (the logs aren't very helpful) that seems to be related
# to fields with non-standard values (namely wrapped URIs). So our current solution is to
# explicitly declare what fields are returned.
#
# @todo is :note admin only?
json.id(@curation_concern.id)

# titles
json.title(@curation_concern.title.map(&:to_s))
json.title_alternative(@curation_concern.title_alternative.map(&:to_s))
json.subtitle(@curation_concern.subtitle.map(&:to_s))

# creators
json.extract!(@curation_concern, :creator, :contributor, :editor, :publisher)

# descriptions
json.extract!(@curation_concern, :resource_type)
json.abstract(@curation_concern.abstract.map(&:to_s))
json.description(@curation_concern.description.map(&:to_s))
json.extract!(@curation_concern, :bibliographic_citation)

# subjects, locations, identifiers
json.subject(map_uris(@curation_concern.subject))
json.extract!(@curation_concern, :keyword)
json.location(map_uris(@curation_concern.location))
json.extract!(@curation_concern, :identifier, :source, :language, :physical_medium, :related_resource)

# dates
json.extract!(@curation_concern, :date_issued, :date_available, :date_uploaded, :date_modified)

# academic dept. info
json.extract!(@curation_concern, :academic_department, :division, :organization)

# rights stuff
json.rights_statement(map_uris(@curation_concern.rights_statement))
json.extract!(@curation_concern, :rights_holder, :license)

json.version(@curation_concern.etag)
