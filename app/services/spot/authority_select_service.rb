# frozen_string_literal: true
module Spot
  class AuthoritySelectService < ::Hyrax::QaSelectService
    def initialize
      super('remote_authorities')
    end

    # return the select options for +*keys+
    #
    # @param [Symbol, String] *keys
    # @return [Array<Hash<String => *>]
    def select_options_for(*keys)
      keys
        .flatten
        .map { |key| authority.find(key.to_s).reject { |k, _v| k == 'id' } }
        .reject(&:blank?) # prevents [{}, {}] issues
    end
  end
end
