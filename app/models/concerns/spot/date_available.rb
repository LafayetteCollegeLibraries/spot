# frozen_string_literal: true
module Spot
  # Mixin to add a #date_available metadata property to a work. Also defines a
  # #set_date_available! method used to set the property that determines whether
  # to use an embargo's release date (when present), or the date when the method was called.
  #
  # @example
  #   class NewspaperWork < ActiveFedora::Base
  #     include Spot::CoreMetadata
  #     include Spot::DateAvailable
  #   end
  #
  #   work = NewspaperWork.new(title: ['Newspaper for March 14, 2022'])
  #   work.persisted?
  #   #=> false
  #   work.date_available
  #   #=> []
  #   work.set_date_available!
  #   work.persisted?
  #   #=> true
  #   work.date_available
  #   #=> ["2022-03-14"]
  #
  # @example Work with an embargo
  #   work = NewspaperWork.find('abc123def')
  #   work.date_available
  #   #=> []
  #   work.embargo_release_date
  #   #=> "2121-03-14"
  #   work.set_date_available!
  #   #=> "2121-03-14"
  #
  module DateAvailable
    extend ActiveSupport::Concern

    included do
      property :date_available, predicate: ::RDF::Vocab::DC.available do |index|
        index.as :symbol
      end
    end

    # Sets the date_available property with either a Time/Date object
    # (anything that responds to #strftime), or automatically depending on:
    #   - if an embargo_release_date is present, then that date
    #   - the current date when the method is called
    #
    # Intended to be called at the end of an object's creation cycle
    # (on submit or at the end of a workflow), as this describes the
    # point in which the object was available to view within the repository.
    #
    # @param [#strftime] time
    # @return [true]
    def set_date_available!
      self.date_available = [determine_date_available]
      save!
    end

    private

    def determine_date_available
      if embargo_release_date&.present?
        embargo_release_date.strftime(time_format)
      else
        Time.zone.now.strftime(time_format)
      end
    end

    def time_format
      '%Y-%m-%d'
    end
  end
end
