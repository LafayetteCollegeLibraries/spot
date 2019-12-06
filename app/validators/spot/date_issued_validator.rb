# frozen_string_literal: true
module Spot
  # Validates the date_issued field of records by ensuring that:
  #   - the record contains exactly one value (+{1,1}+ requirement)
  #   - the value matches either +YYYY-MM-DD+ or +YYYY-MM+ formatting
  #
  # @example Integrating with a model
  #   class Work < ActiveFedora::Base
  #     validates_with ::Spot::DateIssuedValidator, fields: [:date_issued]
  #
  #     # ... etc
  #   end
  #
  class DateIssuedValidator < ::ActiveModel::Validator
    # @param [ActiveFedora::Base] record
    # @return [void]
    def validate(record)
      record.errors[:date_issued] << 'Date Issued may not be blank' if record.date_issued.empty?
      record.errors[:date_issued] << 'Date Issued may only contain one value' if record.date_issued.size > 1

      record.date_issued.each do |date|
        record.errors[:date_issued] << 'Date Issued must be in YYYY-MM-DD, YYYY-MM, or YYYY format' unless
          date.match?(/\A\d{4}(-\d{2}){0,2}\z/)
      end
    end
  end
end
