# frozen_string_literal: true
module Spot
  # An attempt to allow multiple fields to be validated by the same
  # class. Requires a new invocation for each property, as an authority
  # name needs to be provided (guessing one by the field name just seemed
  # like a riskier thing to ask).
  #
  # @example
  #   class Work < ActiveFedora::Base
  #     validates_with RequiredLocalAuthorityValidator,
  #                    field: :resource_type, authority: 'resource_types'
  #   end
  #
  class RequiredLocalAuthorityValidator < ::ActiveModel::Validator
    def validate(record)
      authority_name = options[:authority]
      field = options[:field]
      authority = authority_for(authority_name)

      values = record.send(field)
      values = Array.wrap(values) unless values.respond_to?(:each)

      values.each do |v|
        value = v.is_a?(ActiveTriples::Resource) ? v.id : v.to_s
        record.errors[field] << %("#{value}" is not a valid #{field.to_s.titleize}.) if authority.find(value).empty?
      end
    end

  private

    def authority_for(name)
      # try the name
      return Qa::Authorities::Local::FileBasedAuthority.new(name) if authority_exists?(name)

      # otherwise oops!
      raise "Authority doesn't exist: #{name}"
    end

    def authority_exists?(name)
      File.exist?(Rails.root.join('config', 'authorities', "#{name}.yml"))
    end
  end
end
