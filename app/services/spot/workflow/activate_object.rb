# frozen_string_literal: true
module Spot
  module Workflow
    module ActivateObject
      # "Inheriting" Hyrax's default actions for activation (setting target#state to active via RDF),
      # and also setting the target's :date_available property to either:
      #   - the work's embargo_release_date (where present)
      #   - the date of activation (when this method was called)
      #
      # The value is set as a "YYYY-MM-DD" date string.
      #
      # @param [Hash] options
      # @option [ActiveFedora::Base] target
      # @option [Sipity::Comment] comment
      # @option [User] user
      # @return [true]
      def self.call(target:, **kwargs)
        # Since Hyrax::Workflow::ActivateObject is a module (and not a class)
        # we can't really inherit it, so instead we'll call it
        Hyrax::Workflow::ActivateObject.call(target: target, **kwargs)
        return true if target.respond_to?(:date_available) && target.date_available.present?

        if target.respond_to?(:date_available=) && target.date_available.blank?
          date =
            if target.try(:embargo) && target.embargo.try(:embargo_release_date).present?
              target.embargo.embargo_release_date
            else
              Time.zone.now
            end

          target.date_available = [date.strftime('%Y-%m-%d')]
        end

        true
      end
    end
  end
end
