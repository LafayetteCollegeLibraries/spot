# frozen_string_literal: true
#
# Checks the validity of a BagIt-style directory:
#   - does it exist?
#   - is it a directory?
#   - is the Bag metadata valid?
#
require 'bagit'

module Spot::Validators
  class BagValidator < Darlingtonia::Validator
    private

      # Called from {#validate}
      #
      # @param [Darlingtonia::Parser] parser
      # @return [Array<String>] errors encountered
      def run_validation(parser:, **)
        return ['Bag does not exist'] unless File.exist?(parser.file)
        return ['Bag is not a directory'] unless File.directory?(parser.file)

        bag = BagIt::Bag.new(parser.file)
        return [] if bag.valid?

        bag_errors(bag).reject { |e| e == 'is invalid' }
      end

      # BagIt uses the Validatable gem, which stores its errors according to
      # validation keys. `bag.errors` is a Validatable::Errors object, which
      # looks like
      #
      #   <Validatable::Errors:0x00007f98afa14740 @errors={:consistency=>["error message", "is invalid"]}>
      #
      # so we'll need a long chain to just get the values, aka the messages,
      # of the errors
      #
      # @param [BagIt::Bag] bag
      # @return [Array<String>]
      def bag_errors(bag)
        bag.errors.errors.values.flatten
      end
  end
end
