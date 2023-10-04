# frozen_string_literal: true

require 'csv'
module Bulkrax
  class CsvSpotParser < CsvParser # rubocop:disable Metrics/ClassLength
    def build_records
      @collections = []
      @works = []
      @file_sets = []

      true
    end
  end
end
