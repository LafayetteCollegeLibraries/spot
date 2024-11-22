# frozen_string_literal: true
module Spot
  module Listeners
    extend ActiveSupport::Autoload

    autoload :MintHandleListener
    autoload :ParentCollectionMembershipListener
    autoload :SolrSuggestDictionariesListener
  end
end
