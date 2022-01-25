# frozen_string_literal: true
module Spot
  class CsvParser < ::Bulkrax::CsvParser
    # Just for now
    #
    # @return [false]
    def self.import_supported?
      false
    end
  end
end
