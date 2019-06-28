# frozen_string_literal: true
#
# Replacement for FileSetAccessMasterService that generates
# an access master in a similar fashion (maybe that needs to
# be abstracted out?) but uploads the object to an S3 bucket,
# where it will be grabbed by the IIIF server.
#
# +Hyrax::FileSetDerivativesService+ already handles creating
# the thumbnail. We just want to create an access master for
# an image server to be able to retrieve.
#
# Note: for now we're going with pyramidal TIFs as a uniform
# format for our access masters. The community consensus seems
# to point to JPEG2000s or pyramidal TIFs as access masters.
# The former seems to require Kakadu (a paid software) to get
# the best results, while the later seems to be fairly standard.
#
# From https://mw2016.museumsandtheweb.com/paper/iiif-unshackle-your-images/:
#
# > If you want a free performant option, we would suggest the use
# > of Pyramidal TIFFs. When used in conjunction with a high-performance
# > image server, this format will give you the performance required
# > to implement IIIF.
#
# Note: this requires the following environment variables to be defined:
#   - AWS_ACCESS_KEY_ID
#   - AWS_ACCESS_MASTER_BUCKET
#   - AWS_REGION
#   - AWS_SECRET_ACCESS_KEY
#
# @example basic usage
#   fs = FileSet.find('abc123def')
#   working_dir = Hyrax::WorkingDirectory.new(fs.files.first.id, fs.id)
#   service = Spot::AwsAccessMasterService.new(fs)
#   service.create_derivatives(working_dir)

require 'tmpdir'
require 'digest/md5'

module Spot
  class AwsAccessMasterService
    attr_reader :file_set

    delegate :uri, :mime_type, to: :file_set

    # @param [FileSet] file_set
    def initialize(file_set)
      @file_set = file_set
    end

    # @return [void]
    def cleanup_derivatives
      return nil unless aws_credentials_present?

      client.delete_object(bucket: bucket, key: access_master_filename)
    end

    # @param [String, Pathname] filename
    # @return [void]
    def create_derivatives(filename)
      return nil unless aws_credentials_present?

      create_access_master(src: filename) { |path| upload_object_to_s3(path) }
    end

    # @return [true, false]
    def valid?
      image_mime_types.include? mime_type
    end

    private

      # @return [String]
      def access_master_filename
        "#{file_set.id}-access_master.tif"
      end

      # Are all the credentials we need present?
      #
      # @return [true, false]
      def aws_credentials_present?
        %w[
          AWS_ACCESS_KEY_ID
          AWS_ACCESS_MASTER_BUCKET
          AWS_REGION
          AWS_SECRET_ACCESS_KEY
        ].all? { |k| ENV[k].present? }
      end

      # @return [String]
      def bucket
        ENV['AWS_ACCESS_MASTER_BUCKET']
      end

      # Calculates a base64 digest to send with the PUT action
      # to ensure that our bits make it to AWS intact.
      #
      # @param [IO] io
      # @return [String]
      def calculate_md5(io)
        Digest::MD5.new.tap do |md5|
          io.each { |chunk| md5.update(chunk) }
          io.rewind
        end.base64digest
      end

      # @return [Aws::S3::Client]
      def client
        @client ||= Aws::S3::Client.new
      end

      def create_access_master(src:)
        Dir.mktmpdir do |tmpdir|
          out_path = File.join(tmpdir, access_master_filename)

          MiniMagick::Tool::Magick.new do |magick|
            magick << src
            # note: we need to use an array for each piece of this command;
            # using a string will cause an error
            magick.merge! %w[-define tiff:tile-geometry=128x128]
            magick << "ptif:#{out_path}"
          end

          yield out_path if block_given?
        end
      end

      # @return [Array<String>]
      def image_mime_types
        FileSet.image_mime_types
      end

      # @param [String, Pathname] pathname
      # @return [void]
      def upload_object_to_s3(pathname)
        io = File.open(pathname, 'rb')

        client.put_object(
          body: io,
          bucket: bucket,
          content_md5: calculate_md5(io),
          key: access_master_filename
        )
      end
  end
end
