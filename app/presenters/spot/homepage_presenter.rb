# frozen_string_literal: true
module Spot
  class HomepagePresenter
    attr_reader :recent_items, :featured_collections

    def initialize(recent_items, featured_collections)
      @recent_items = recent_items
      @featured_collections = featured_collections
    end

    def show_senior_honors_thesis_block?
      Flipflop.enabled?(:show_senior_honors_thesis_block)
    end
  end
end
