# frozen_string_literal: true
module Spot
  # Hacking the derivatives creation process to be more of a pipeline rather than per mime-type.
  # Individual service classes are stored within the `.derivative_services` class_attribute, and
  # when Spot::FileSetDerivativesService#create_derivatives or `#cleanup_derivatives`` is invoked,
  # each sub-service receives the same call (if it responds true to `#valid?`).
  class FileSetDerivativesService < ::Hyrax::DerivativeService
    class_attribute :derivative_services, :supported_mime_types
    self.derivative_services = [
      ::Spot::Derivatives::ThumbnailService,
      ::Spot::Derivatives::IiifAccessCopyService,
      ::Spot::Derivatives::TextExtractionService,
      ::Spot::Derivatives::AudioDerivativeCopyService,
      ::Spot::Derivatives::VideoDerivativeCopyService
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
      services.any?(&:valid?)
    end

    private

    def services
      derivative_services.map { |service| service.new(file_set) }
    end
  end
end
