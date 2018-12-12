# frozen_string_literal: true

# Checks a BagIt directory for a "metadata.csv" file living at the root of
# the +data/+ directory.
module Spot::Validators
  class BagMetadataValidator < Darlingtonia::Validator
    private

    def run_validation(parser:, **)
      [].tap do |errors|
        unless File.exist?(File.join(parser.file, 'data', 'metadata.csv'))
          errors << 'Bag does not have a "data/metadata.csv" file'
        end
      end
    end
  end
end
