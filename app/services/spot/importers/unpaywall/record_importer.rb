# frozen_string_literal: true

module Spot::Importers::Unpaywall
  class RecordImporter < ::Spot::Importers::Base::RecordImporter
  private

    # Method used to construct a warning
    #
    # @param [Hash] attributes
    # @return [String] an error message
    def empty_file_warning(attributes)
      "[WARN] no open-access files available for #{attributes[:title]}\n"
    end
  end
end
