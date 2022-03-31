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

        if target.respond_to?(:date_available=) && target.date_available.blank?
          date = target.embargo_release_date || Time.zone.now
          target.date_available = [date.strftime('%Y-%m-%d')]
        end

        # Explicitly returning true because the :date_available= guard may return false
        # for models without the property defined, which will cause the work to not be saved
        # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/services/hyrax/workflow/action_taken_service.rb#L24-L32
        true
      end
    end
  end
end
