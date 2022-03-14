# frozen_string_literal: true
module Spot
  module Workflow
    class ActivateObject < ::Hyrax::Workflow::ActivateObject
      def call(target:, **)
        super

        target.set_date_available! if target.respond_to?(:set_date_available!)
      end
    end
  end
end
