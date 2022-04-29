# frozen_string_literal: true
module Hyrax
  class StudentWorksController < ApplicationController
    include Spot::WorksControllerBehavior

    self.curation_concern_type = ::StudentWork
    self.show_presenter = Hyrax::StudentWorkPresenter
    self.search_builder_class = ::Spot::StudentWorkSearchBuilder
  end
end
