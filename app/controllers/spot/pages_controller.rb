# frozen_string_literal: true
#
# The controller to support individual pages for our site.
module Spot
  class PagesController < ApplicationController
    def homepage
      render layout: '1_column_no_navbar'
    end
  end
end
