# frozen_string_literal: true
module Spot
  module Listeners
    extend ActiveSupport::Autoload

    autoload :ParentCollectionMembershipListener
    autoload :SolrSuggestDictionariesListener
  end
end