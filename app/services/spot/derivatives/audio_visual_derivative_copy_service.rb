# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'

module Spot
  module Derivatives
    # Checks the 'premade_derivatives' property on the associated work. If the property is empty,
    # generates derivatives (mp3 and mp4 for audio and video) and sends them to an s3 bucket. If
    # the 'premade_derivatives' field is not empty, then moves the associated derivative to the
    # correct bucket with a new name.
    #
    # Derivatives are either generated locally and then posted to the s3 bucet defined by
    # the AWS_AUDIO_VISUAL_BUCKET environment variable, or they exist already and are moved from
    # the AWS_BULKRAX_IMPORTS_BUCKET to the AWS_AUDIO_VISUAL_BUCKET. Local copies are deleted afterwards.
    #
    # These derivatives are created for an FileSets that include Audio or Video mime_types.
    #
    # @see https://www.loc.gov/preservation/digital/formats/fdd/fdd000237.shtml
    class AudioVisualDerivativeCopyService < BaseDerivativeService
      class_attribute :audio_derivative_key_template
      class_attribute :video_derivative_key_high_template
      class_attribute :video_derivative_key_low_template
      self.audio_derivative_key_template = '%s-access.mp3'
      self.video_derivative_key_high_template = '%s-access-high.mp4'
      self.video_derivative_key_low_template = '%s-access-low.mp4'

      # Deletes the derivative from the S3 bucket
      # @todo maybe we should hang onto these when we delete + put them in a glacier grave?
      # @return [void]
      # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#delete_object-instance_method
      def cleanup_derivatives
        s3_derivative_key.each do |key|
          s3_client.delete_object(bucket: s3_bucket, key: key)
        end
      end

      # Generates a pyramidal TIFF using ImageMagick (via MiniMagick gem)
      # and uploads it to the S3 bucket.
      #
      # @param [String,Pathname] filename the src path of the file
      # @return [void]
      def create_derivatives(filename)
        return if check_premade_derivatives

        if audio_mime_types.include?(mime_type)
          create_audio_derivatives(filename)
        else
          create_video_derivatives(filename)
        end

        upload_derivative_to_s3
        derivative_path.each do |path|
          FileUtils.rm_f(path) if File.exist?(path)
        end
      end

      # Check to see if any premade derivatives exist, process them if so.
      #
      # @return [Boolean]
      def check_premade_derivatives
        premade_derivatives = file_set.parent.premade_derivatives.to_a

        return false if premade_derivatives.empty?

        premade_derivatives.each_with_index do |derivative, index|
          transfer_s3_derivative(derivative, index)
        end

        true
      end

      def derivative_path
        if audio_mime_types.include?(mime_type)
          [audio_derivative_path]
        else
          [video_derivative_path_high, video_derivative_path_low]
        end
      end

      # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
      # but modifies the filename it writes out to.
      #
      # @return [String]
      def audio_derivative_path
        @audio_derivative_path ||=
          Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access.mp3').to_s.gsub(/\.access\.mp3$/, '')
      end

      # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
      # but modifies the filename it writes out to.
      #
      # @return [String]
      def video_derivative_path_high
        @video_derivative_path_high ||=
          Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access-high.mp4').to_s.gsub(/\.access-high\.mp4$/, '')
      end

      # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
      # but modifies the filename it writes out to.
      #
      # @return [String]
      def video_derivative_path_low
        @video_derivative_path_low ||=
          Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access-low.mp4').to_s.gsub(/\.access-low\.mp4$/, '')
      end

      def derivative_url
        ret = []
        derivative_path.each do |path|
          ret.push(URI("file://#{path}").to_s)
        end
        ret
      end

      # Only create pyramidal TIFFs if the source mime_type is an Image and if we defined
      def valid?
        if s3_bucket.blank?
          Rails.logger.warn('Skipping audio derivative generation because the AWS_AUDIO_VISUAL_BUCKET environment variable is not defined.')
          return false
        end

        audio_mime_types.include?(mime_type) || video_mime_types.include?(mime_type)
      end

      private

      def create_audio_derivatives(filename)
        Hydra::Derivatives::AudioDerivatives.create(filename,
                                                    outputs: [{ label: 'mp3', format: 'mp3', url: derivative_url[0] }])
      end

      def create_video_derivatives(filename)
        Hydra::Derivatives::VideoDerivatives.create(filename,
                                                    outputs: [{ label: 'high',
                                                                format: 'mp4',
                                                                url: derivative_url[0], 
                                                                size: "1920x1080", 
                                                                input_options: "-t 10 -ss 1", 
                                                                video: "-g 30 -b:v 8000k", 
                                                                audio: "-b:a 256k -ar 44100" },
                                                              { label: 'low',
                                                                format: 'mp4',
                                                                url: derivative_url[1], 
                                                                size: "640x480", 
                                                                input_options: "-t 10 -ss 1", 
                                                                video: "-g 30 -b:v 2500k", 
                                                                audio: "-b:a 256k -ar 44100" }])
      end

      def s3_bucket
        ENV['AWS_BULKRAX_IMPORTS_BUCKET']
      end

      def s3_source
        ENV['AWS_BULKRAX_IMPORTS_BUCKET']
      end

      # We're using AWS credentials stored within the App/Sidekiq services for authentication,
      # so the Aws::S3::Client will pick them up ambiently.
      def s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      def s3_derivative_key
        if audio_mime_types.include?(mime_type)
          [audio_derivative_key_template % file_set.id]
        else
          [video_derivative_key_high_template % file_set.id,
          video_derivative_key_low_template % file_set.id]
        end
      end

      def upload_derivative_to_s3
        derivative_path.each_with_index do |path, index|
          s3_client.put_object(
            bucket: s3_bucket,
            key: s3_derivative_key[index],
            body: File.open(path, 'r'),
            content_length: File.size(path),
            content_md5: Digest::MD5.file(path).base64digest,
            metadata: {}
          )
        end
      end

      def transfer_s3_derivative(derivative, index)
        src = "/" + s3_source + "/" + derivative
        s3_client.copy_object(
          bucket: s3_bucket,
          copy_source: src,
          key: s3_derivative_key[index]
        )
      end
    end
  end
end
