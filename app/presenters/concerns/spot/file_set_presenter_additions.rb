# frozen_string_literal: true
module Spot
  module FileSetPresenterAdditions
    extend ActiveSupport::Concern

    included do
      delegate :original_filenames, :transcript_name, :stored_derivatives, to: :solr_document
    end
  end
end
