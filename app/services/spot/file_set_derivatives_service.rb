# frozen_string_literal: true
module Spot
  # Hacking the derivatives creation process to be more of a pipeline rather than per mime-type.
  class FileSetDerivativesService < ::Hyrax::DerivativeService
    class_attribute :derivative_services
    self.derivative_services = [
      ::Spot::Derivatives::ThumbnailService,
      ::Spot::Derivatives::IiifAccessCopyService,
      ::Spot::Derivatives::TextExtractionService
    ]

    def cleanup_derivatives
      services.each do |service|
        service.cleanup_derivatives if service.valid?
      end
    end

    def create_derivatives(working_copy_src)
      services.each do |service|
        service.create_derivatives(working_copy_src) if service.valid?
      end
    end

    def valid?
      supported_mime_types.include? mime_type
    end

    private

    def supported_mime_types
      file_set.class.pdf_mime_types + file_set.class.image_mime_types
    end

    def services
      derivative_services.map { |service| service.new(file_set) }
    end
  end
end
