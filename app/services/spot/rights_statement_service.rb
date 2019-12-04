# frozen_string_literal: true
module Spot
  # Duplicates the work in +Hyrax::RightsStatementService+ and adds
  # support for looking up a shortcode by an URI.
  class RightsStatementService < ::Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('rights_statements')
    end

    ##
    # @param id [String]
    #
    # @return [String] the label for the authority
    #
    # @yield when no 'term' value is present for the id
    # @yieldreturn [String] an alternate label to return
    #
    # @raise [KeyError] when no 'term' value is present for the id
    def shortcode(id, &block)
      authority.find(id).fetch('shortcode', &block)
    end
  end
end
