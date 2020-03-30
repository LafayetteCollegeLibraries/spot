# frozen_string_literal: true
module Spot
  class AuthoritySelectService < ::Hyrax::QaSelectService
    def initialize
      super('remote_authorities')
    end

    def select_options_for(*ids)
      ids.map { |id| authority.find(id.to_s).reject { |k, _v| k == 'id' } }
    end
  end
end
