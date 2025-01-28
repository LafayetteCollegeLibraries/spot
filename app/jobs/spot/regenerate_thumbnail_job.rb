# frozen_string_literal: true
module Spot
  # Job that allows us to recreate thumbnails without having to run the entirety of
  # +CreateDerivativesJob+ which generates pyramidal tiffs, extracts full-text content,
  # basically a whole lot of work that we might not need to repeat.
  class RegenerateThumbnailJob < ApplicationJob
    def perform(work)
      @work = work
      return if work&.thumbnail_id.nil?

      file_set = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: work.thumbnail_id)
      filename = Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')
      Spot::Derivatives::ThumbnailService.new(file_set).create_derivatives(filename)

      # I think we need to at least persist the Resource so that the updated thumbnail path is saved
      [work, file_set].each { |obj| Hyrax.persister.save(resource: obj) }

      true
    rescue ::Valkyrie::Persistence::ObjectNotFoundError, ActiveFedora::ObjectNotFoundError, Ldp::Gone
      Rails.logger.warn("Unable to regenerate thumbnail for deleted work #{@work.id}")
      true
    end
  end
end
