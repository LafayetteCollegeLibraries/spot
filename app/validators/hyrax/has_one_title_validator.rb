# frozen_string_literal: true
module Hyrax
  # Locally modified version of Hyrax code to allow RDF literal values to be passed as titles.
  # (Previously was failing because Literals do not have an :empty? method). All this is doing
  # is stringifying the values in `record.title` before checking their validity.
  #
  # validates that the title has at least one title
  class HasOneTitleValidator < ActiveModel::Validator
    def validate(record)
      return unless record.title.map(&:to_s).reject(&:empty?).empty?
      record.errors[:title] << "You must provide a title"
    end
  end
end
