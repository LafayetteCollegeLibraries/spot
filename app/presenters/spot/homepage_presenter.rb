# frozen_string_literal: true
module Spot
  class HomepagePresenter
    attr_reader :recent_items

    def initialize(recent_items)
      @recent_items = recent_items
    end
  end
end
