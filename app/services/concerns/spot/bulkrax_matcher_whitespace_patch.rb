# frozen_string_literal: true
module Spot
  module BulkraxMatcherWhitespacePatch
    extend ActiveSupport::Concern

    def result(_parser, content)
      return nil if self.excluded == true || Bulkrax.reserved_properties.include?(self.to)
      # rubocop:disable Style/RedundantParentheses
      return nil if self.if && (!self.if.is_a?(Array) && self.if.length != 2)
      # rubocop:enable Style/RedundantParentheses
      if self.if
        return unless content.send(self.if[0], Regexp.new(self.if[1]))
      end

      # @result will evaluate to an empty string for nil content values
      @result = content.to_s.gsub(/\t/, ' ').strip # remove any tabs + leading/trailing spaces but leave line breaks
      # blank needs to be based to split, only skip nil
      process_split unless @result.nil?
      @result = @result[0] if @result.is_a?(Array) && @result.size == 1
      process_parse
      return @result
    end
  end
end