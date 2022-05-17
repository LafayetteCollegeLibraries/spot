# frozen_string_literal: true
module Spot::Importers::CSV
  class InputRecord < ::Darlingtonia::InputRecord
    def attributes
      super.select { |_key, value| value.present? }
    end
  end
end
