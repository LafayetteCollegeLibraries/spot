# frozen_string_literal: true
#
# Adds additional metadata formats to a +Hyrax::WorksControllerBehavior+
# controller by adding formats to the +additional_response_formats+ method.
module Spot
  module AdditionalFormatsForController
    # Adds additional formats to our additional formats option
    #
    # @return [void]
    def additional_response_formats(format)
      format.csv { send_data(work_as_csv, type: 'text/csv', filename: csv_filename) }

      super if defined?(super)
    end

    private

      # @return [String]
      def csv_filename
        "#{presenter.id}.csv"
      end

      # @return [String]
      def work_as_csv
        Spot::WorkCSVService.for(presenter.solr_document)
      end
  end
end
