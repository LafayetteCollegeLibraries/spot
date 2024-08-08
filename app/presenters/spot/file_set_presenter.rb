# frozen_string_literal: true
module Spot
  class FileSetPresenter < ::Hyrax::FileSetPresenter
    delegate :original_filenames, to: :solr_document
  end
end
