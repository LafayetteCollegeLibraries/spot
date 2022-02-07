# frozen_string_literal: true
module Spot
  class PdfDerivativesService
    class_attribute :services
    self.services = [::Spot::Derivatives::ThumbnailService]

    attr_reader :file_set
    delegate :uri, :mime_type, to: :file_set

    def initialize(file_set)
      @file_set = file_set
    end

    # Delegates cleanup to each of our services
    #
    # @return [void]
    def cleanup_derivatives
      mapped_services.each do |service|
        service.cleanup_derivatives if service.respond_to?(:cleanup_derivatives)
      end
    end

    # Iterates through the the provided services and runs their +#create_derivatives+
    # method to allow us to do more than one thing with an image type
    #
    # @param [String, Pathname] filename
    # @return [void]
    def create_derivatives(filename)
      mapped_services.each do |service|
        service.create_derivatives(filename) if service.respond_to?(:create_derivatives)
      end
    end

    # Does the file_set we're processing have an image-esque mime-type?
    #
    # @return [true, false]
    def valid?
      file_set.class.pdf_mime_types.include?(mime_type)
    end

    private

    # @return [Array<Spot::Derivatives::BaseDerivativesService>]
    def mapped_services
      @mapped_services ||= services.map { |service| service.new(file_set) }
    end
  end
end
