# frozen_string_literal: true
module Spot
  module Derivatives
    # Base class that other derivative services can inherit from
    class BaseDerivativeService < ::Hyrax::DerivativeService
      delegate :audio_mime_types,
               :image_mime_types,
               :pdf_mime_types,
               :office_document_mime_types,
               :video_mime_types,
               to: :FileSet
    end
  end
end
