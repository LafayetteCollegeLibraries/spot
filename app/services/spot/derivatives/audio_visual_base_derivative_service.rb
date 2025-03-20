# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'
require 'ffprober'

module Spot
  module Derivatives
    # Base file that audio and video derivative services inherit from. Contains functionality common to both.
    #
    # Checks the 'premade_derivatives' property on the associated work. If the property is empty,
    # generates derivatives (mp3 and mp4 for audio and video) and sends them to an s3 bucket. If
    # the 'premade_derivatives' field is not empty, then moves the associated derivative to the
    # correct bucket with the correct name.
    #
    # Derivatives are either generated locally and then posted to the s3 bucet defined by
    # the AWS_AUDIO_VISUAL_BUCKET environment variable, or they exist already and are moved from
    # the AWS_BULKRAX_IMPORTS_BUCKET to the AWS_AUDIO_VISUAL_BUCKET. Local copies are deleted afterwards.
    #
    # These derivatives are created for an FileSets that include Audio or Video mime_types.
    #
    # @see https://www.loc.gov/preservation/digital/formats/fdd/fdd000237.shtml
    class AudioVisualBaseDerivativeService < BaseDerivativeService
      # Pulls a list of objects in the AudioVisual bucket and deletes those which are prefixed
      # by the fileset id of the given fileset.
      # @todo maybe we should hang onto these when we delete + put them in a glacier grave?
      # @return [void]
      # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#delete_object-instance_method
      def cleanup_derivatives
        prefix = file_set_resource.id + "-"
        object_list = s3_client.list_objects(bucket: s3_bucket, prefix: prefix).to_h[:contents]
        return if object_list.nil?

        delete = { objects: [], quiet: false }
        object_list.each do |object|
          delete[:objects].push({ key: object[:key] })
        end
        s3_client.delete_objects(bucket: s3_bucket, delete: delete)
      end

      # Placeholder for file specific paths in children
      # :nocov:
      def derivative_paths; end
      # :nocov:

      # make urls out of derivative paths
      def derivative_urls
        derivative_paths.map { |path| URI("file://#{path}").to_s }
      end

      # Check mime types, overwritten by children
      def valid?
        return no_bucket_warning if s3_bucket.blank?

        audio_mime_types.include?(mime_type) || video_mime_types.include?(mime_type)
      end

      def file_set_resource
        @file_set_resource ||=
          Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: file_set.id)
      end

      private

      def no_bucket_warning
        Hyrax.logger.warn('Skipping audio derivative generation because the AWS_AUDIO_VISUAL_BUCKET environment variable is not defined.')
        false
      end

      def premade_derivative_key_with_suffix(filename, suffix: '_derivative')
        file_key = File.basename(filename, '.*')
        project_name = file_key.split('_').first
        suffix = suffix.start_with?('_') ? suffix : "_#{suffix}"

        "#{project_name}/#{file_key}#{suffix}".strip
      end

      # destination for av derivatives
      def s3_bucket
        ENV['AWS_AV_ASSET_BUCKET']
      end

      # source for premade derivatives
      def s3_source
        ENV['AWS_BULKRAX_IMPORTS_BUCKET']
      end

      # We're using AWS credentials stored within the App/Sidekiq services for authentication,
      # so the Aws::S3::Client will pick them up ambiently.
      def s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      # Placeholder for derivative keys in children
      # :nocov:
      def s3_derivative_keys; end
      # :nocov:

      # Uploads generated derivatives specified by paths with new names specified by
      # keys to the s3 bucket. Adds all uploaded keys to the stored_derivatives metadata field
      def upload_derivatives_to_s3(keys, paths)
        stored_derivatives = file_set_resource.stored_derivatives.to_a
        paths.each_with_index do |path, index|
          stored_derivatives.push(keys[index])
          s3_client.put_object(
            bucket: s3_bucket,
            key: keys[index],
            body: File.open(path, 'r'),
            content_length: File.size(path),
            content_md5: Digest::MD5.file(path).base64digest,
            metadata: {}
          )
        end
        file_set_resource.stored_derivatives = stored_derivatives
        Hyrax.persister.save(resource: file_set_resource)
      end

      # Transfers a single derviative from the source bucket to the destination bucket, renaming
      # it. Adds all uploaded keys to the stored_derivatives metadata field
      def transfer_s3_derivative(derivative, key)
        stored_derivatives = file_set_resource.stored_derivatives.to_a
        stored_derivatives.push(key)
        file_set_resource.stored_derivatives = stored_derivatives
        Hyrax.persister.save(resource: file_set_resource)
        src = "/" + s3_source + "/" + derivative
        s3_client.copy_object(
          bucket: s3_bucket,
          copy_source: src,
          key: key
        )
      end
    end
  end
end
