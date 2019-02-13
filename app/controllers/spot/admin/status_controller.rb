# frozen_string_literal: true
#
# Adapting the OkComputer status page to a "nicer" tabular
# layout within the admin dashboard.
module Spot
  module Admin
    class StatusController < ApplicationController
      with_themed_layout 'dashboard'

      # run the checks + provide the results to the view
      def show
        checks = OkComputer::Registry.all
        checks.run

        @checks = checks.collection
      end
    end
  end
end
