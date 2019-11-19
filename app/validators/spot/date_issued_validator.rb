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
      if record.date_issued.empty?
        record.errors[:date_issued] << 'Date Issued may not be blank'
      end

      if record.date_issued.size > 1
        record.errors[:date_issued] << 'Date Issued may only contain one value'
      end

      record.date_issued.each do |date|
        unless date.match?(/\A\d{4}-\d{2}(-\d{2})?\z/)
          record.errors[:date_issued] << 'Date Issued must be in YYYY-MM-DD or YYYY-MM format'
        end
      end
    end
  end
end
