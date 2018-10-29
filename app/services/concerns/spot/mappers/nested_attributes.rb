# frozen_string_literal: true

# Helper method to create an attributes hash for a field.
# The raw value is yielded to the block (when provided,
# otherwise it's a no-op).
module Spot::Mappers::NestedAttributes
  def nested_attributes_hash_for(field)
    return {} if metadata[field].blank?

    mapped_values = metadata[field].map do |raw_value|
      yield raw_value if block_given?
    end.reject(&:blank?)

    return {} if mapped_values.blank?

    mapped_values.each_with_object({}).with_index do |(id, obj), idx|
      obj[idx.to_s] = { 'id' => id }
    end
  end
end
