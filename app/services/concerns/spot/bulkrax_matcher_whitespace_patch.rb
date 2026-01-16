# frozen_string_literal: true
module Spot
  # Patch to preserve newlines in incoming metadata. Bulkrax's default is to call `gsub(/\s/, ' ')` on the
  # raw contents _before_ passing the value to a parse method, so we don't really have direct access to
  # the original parsed value unless #result is patched.
  #
  # @see spec/matchers/bulkrax/application_matcher_spec.rb (for specs)
  # @see config/initializers/spot_overrides.rb (for inclusion)
  # @see https://github.com/samvera/bulkrax/blob/v9.1.0/app/matchers/bulkrax/application_matcher.rb#L17C1-L33C8
  module BulkraxMatcherWhitespacePatch
    extend ActiveSupport::Concern

    # This is copied verbatim from Hyrax source, save for the gsub modification, and
    # as such Rubocop needs to back off.
    #
    # rubocop:disable all
    def result(_parser, content)
      return nil if self.excluded == true || Bulkrax.reserved_properties.include?(self.to)

      return nil if self.if && (!self.if.is_a?(Array) && self.if.length != 2)
      if self.if
        return unless content.send(self.if[0], Regexp.new(self.if[1]))
      end

      # Overwriting this assignment to @result to only replace tabs with spaces
      # and preserve newlines.
      # @see https://github.com/samvera/bulkrax/blob/v9.1.0/app/matchers/bulkrax/application_matcher.rb#L27

      # @result will evaluate to an empty string for nil content values
      @result = content.to_s.gsub(/\t/, ' ').strip # remove any tabs + leading/trailing spaces but leave line breaks
      # blank needs to be based to split, only skip nil
      process_split unless @result.nil?
      @result = @result[0] if @result.is_a?(Array) && @result.size == 1
      process_parse

      @result
    end

    def parse_remote_files(src)
      return if src.blank?
      src.strip!

      client = Aws::S3::Client.new
      begin
        client.head_object(key: src, bucket: ENV['AWS_BULKRAX_IMPORTS_BUCKET'])
      rescue Aws::S3::Errors::NotFound
        Rails.logger.warn('S3: Key not found.')
        return "S3: Key not found."
      end
      obj = Aws::S3::Object.new(bucket_name: ENV['AWS_BULKRAX_IMPORTS_BUCKET'], key: src, client: client)
      url = obj.presigned_url(:get, expires_in: 3600)

      name = src.split('/')[-1]
      { url: url, file_name: name }
    end
    # rubocop:enable all
  end
end
