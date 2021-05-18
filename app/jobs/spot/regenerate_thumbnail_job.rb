# frozen_string_literal: true
module Spot
  # Job that allows us to recreate thumbnails without having to run the entirety of
  # +CreateDerivativesJob+ which generates pyramidal tiffs, extracts full-text content,
  # basically a whole lot of work that we might not need to repeat.
  class RegenerateThumbnailJob < ApplicationJob
    def perform(work)
      return if work&.thumbnail_id.nil?
      file_set = FileSet.find(work.thumbnail_id)

      filename = Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')
      Spot::Derivatives::ThumbnailService.new(file_set).create_derivatives(filename)

      file_set.reload
      file_set.update_index
      work.update_index

      true
    end
  end
end
