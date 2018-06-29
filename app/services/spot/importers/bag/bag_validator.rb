# frozen_string_literal: true
require 'bagit'

module Spot::Importers::Bag
  class BagValidator < Darlingtonia::Validator
    private

    def run_validation(parser:, **)
      return ['Bag does not exist'] unless File.exist?(parser.file)
      return ['Bag is not a directory'] unless File.directory?(parser.file)

      bag = BagIt::Bag.new(parser.file)
      return [] if bag.valid?

      # BagIt uses the Validatable gem, which stores its errors according to
      # validation keys. `bag.errors` is a Validatable::Errors object, which
      # looks like
      #
      #   <Validatable::Errors:0x00007f98afa14740 @errors={:consistency=>["error message", "is invalid"]}>
      #
      # so we'll need a long chain to just get the values, aka the messages,
      # of the errors

      errors = bag.errors.errors.values.flatten
      errors.reject { |e| e == 'is invalid' }
    end
  end
end
