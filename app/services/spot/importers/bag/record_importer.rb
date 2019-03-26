# frozen_string_literal: true

module Spot::Importers::Bag
  class RecordImporter < ::Spot::Importers::Base::RecordImporter
    private

      def empty_file_warning(_attributes)
        '[WARN] no files found for this bag\n'
      end
  end
end
