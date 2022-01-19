# frozen_string_literal: true
#
# Mixin to fish-out a permalink + assign it to
# a solr field. Will not assign this property
# if an item does not have an `hdl` prefixed
# identifier, and prefers those that contain
# an object's NOID.
module IndexesPermalink
  # @todo: move the handle prefix to a configuration file
  HANDLE_PREFIX = '10385'
  PERMALINK_SOLR_FIELD = 'permalink_ss'

  def generate_solr_document
    super.tap do |doc|
      break doc if permalink.nil?
      doc[PERMALINK_SOLR_FIELD] = permalink
    end
  end

  private

  # Determines the right Handle identifier to use as the permalink.
  # - Are there any +hdl+ prefixed identifiers?
  # - Do these identifiers include the object's NOID?
  # - Otherwise, use the first Handle ID found
  #
  # @return [Spot::Identifier]
  # @todo How to deal with multiple Handle IDs where none of them
  #       include the object's NOID. This is a 'probably never will happen'
  #       circumstance, but I'd like to have a fail-safe rather than
  #       just skipping the permalink.
  def handle_identifier
    return nil if handle_identifiers.empty?
    return handle_identifiers.first if handle_identifiers.size == 1

    noid_handle = handle_identifiers.find do |id|
      id.value == "#{HANDLE_PREFIX}/#{object.id}"
    end

    return noid_handle unless noid_handle.nil?

    # worst case scenario?
    handle_identifiers.first
  end

  # @return [Array<Spot::Identifier>]
  def handle_identifiers
    @handle_identifiers ||=
      object.identifier
            .select { |id| id.start_with? 'hdl' }
            .map { |id| Spot::Identifier.from_string(id) }
  end

  # Provides the URL to the item within the application
  # (fallback in the event that a Handle doesn't exist yet).
  #
  # @return [String]
  def object_in_application_url
    Rails.application.routes.url_helpers.polymorphic_url(object, host: ENV['URL_HOST'])
  end

  # @return [String]
  def permalink
    @permalink ||= begin
      id = handle_identifier
      id ? "http://hdl.handle.net/#{id.value}" : object_in_application_url
    end
  end
end
