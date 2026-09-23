# frozen_string_literal: true
module Spot
  module Derivatives
    # Hyrax derivative service options are set in Hyrax.config.derivative_services and
    # determined by the first to return true to #valid? Hyrax provides a catch-all
    # Hyrax::FileSetDerivativesService that I recommend including at the end of the
    # custom derivative services to pick up file_types not covered by the others.
    #
    # @example configuring services
    #   # config/initializers/hyrax.rb
    #   Hyrax.configure do |config|
    #     config.derivative_services = [
    #       Spot::ImageDerivativesService,
    #       Spot::BaseDerivativeService,
    #       Hyrax::FileSetDerivativesService
    #     ]
    #   end
    #
    # @example Subclassing to handle edge cases
    #   class CoolCustomDerivativeService < Spot::Derivatives::BaseDerivativeService
    #     def cleanup_derivatives
    #       super  # delete thumbnail if exists
    #       # idk cleanup
    #     end
    #
    #     def create_derivatives(file_name)
    #       super  # generate thumbnails + text extract (where applicable)
    #       do_something_with_this_type(file_name)
    #     end
    #
    #     def valid?
    #       file_set.label.include?('transcript')
    #     end
    #
    #     private
    #
    #     def do_something_with_this_type(file_name)
    #       # ...
    #     end
    #   end
    #
    #   Hyrax.config.derivative_services = [
    #     CoolCustomDerivativeService,
    #     Spot::Derivatives::BaseDerivativeService,
    #     Hyrax::FileSetDerivativesService
    #   ]
    #
    # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/jobs/valkyrie_create_derivatives_job.rb#L10
    # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/services/hyrax/file_set_derivatives_service.rb
    class BaseDerivativeService
      delegate :audio_mime_types, :image_mime_types, :pdf_mime_types, :office_document_mime_types, :video_mime_types, to: :FileSet
      delegate :mime_type, to: :file_metadata
      attr_reader :file_metadata

      def initialize(file_metadata)
        @file_metadata = file_metadata
      end

      def cleanup_derivatives
        delete_thumbnail!
      end

      def create_derivatives(src_path)
        create_thumbnail_from(src_path)
        extract_and_save_full_text(src_path) if full_text_eligible_types.include?(mime_type)
      end

      def file_set
        @file_set ||= Hyrax.query_service.find_by(id: file_metadata.file_set_id)
      end

      def valid?
        Hyrax.config.use_valkyrie? && [*pdf_mime_types, *office_document_mime_types].include?(mime_type)
      end

      private

      def create_thumbnail_from(path)
        MiniMagick::Tool::Convert.new do |convert|
          convert.merge!(
            [
              "#{path}[0]",
              "-colorspace", "sRGB",
              "-flatten",
              "-resize", "200x150>",
              "-format", "jpg",
              thumbnail_derivative_path
            ]
          )
        end
      end

      # Copied from Hyrax::FileSetDerivativeService
      #
      # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/services/hyrax/file_set_derivatives_service.rb#L119-L127
      def extract_and_save_full_text(_src_path)
        return unless Hyrax.config.extract_full_text?

        Rails.logger.warn 'Skipping full-text extraction for the moment'
        # outputs = [{ url: full_text_target_uri, container: 'extracted_text' }]
        # Hydra::Derivatives::FullTextExtract.create(src_path, outputs: outputs)
      end

      def delete_thumbnail!
        FileUtils.rm_f(thumbnail_derivative_path) if File.exist?(thumbnail_derivative_path)
      end

      def full_text_eligible_types
        [*image_mime_types, *pdf_mime_types, *office_document_mime_types]
      end

      # @see https://github.com/samvera/hyrax/blob/hyrax-v3.5.0/app/services/hyrax/file_set_derivatives_service.rb#L13-L20
      def full_text_target_uri
        # If given a FileMetadata object, use its parent ID.
        if file_set.respond_to?(:file_set_id)
          file_set.file_set_id.to_s
        else
          file_set.uri
        end
      end

      def thumbnail_derivative_path
        return @thumbnail_derivative_path if @thumbnail_derivative_path.present?

        @thumbnail_derivative_path = Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail').to_s.tap do |path|
          FileUtils.mkdir_p(File.dirname(path)) unless Dir.exist?(File.dirname(path))
        end
      end
    end
  end
end
