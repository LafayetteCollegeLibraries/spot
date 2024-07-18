# frozen_string_literal: true
#
# Mixin to index a permalink for a resource. Uses a Handle value (`hdl` prefix) stored in #identifier
# to generate the handle.net URL, otherwise uses the work's URL within the application.
module IndexesPermalinkUrl
  def to_solr
    super.tap do |document|
      break document if permalink.nil?
      document['permalink_ss'] = permalink
    end
  end

  def handle_identifier
    @handle_identifier ||= begin
      id = resource.identifier.find { |id| id.start_with? 'hdl:' }
      Spot::Identifier.from_string(id)
    end
  end

  def permalink
    @permalink ||= begin
      handle_identifier ? "http://hdl.handle.net/#{handle_identifier.value}" : resource_url
    end
  end

  def resource_url
    Rails.application.routes.url_helpers.polymorphic_url(resource, host: ENV['URL_HOST'])
  end
end