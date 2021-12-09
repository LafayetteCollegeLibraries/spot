# frozen_string_literal: true
#
# Checks a BagIt directory for a "metadata.csv" file living at the root of
# the +data/+ directory.
#
module Spot::Validators
  class BagMetadataValidator < Darlingtonia::Validator
  private

    # Called from within {#validate}. Will return an error if the metadata
    # file does not exist.
    #
    # @param [Darlingtonia::Parser] parser
    # @return [Array<String>]
    def run_validation(parser:, **)
      msg = 'Bag does not have a "data/metadata.csv" file'
      [].tap do |errors|
        errors << msg unless File.exist?(File.join(parser.file, 'data', 'metadata.csv'))
      end
    end
  end
end
