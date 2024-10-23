# frozen_string_literal: true
#
# Tiny job wrapper that calls our PremadeDerivativeService to do the
# heavy-lifting. Calls are per derivative rather than per file set.
module Spot
  class TransferPremadeDerivativeJob < ApplicationJob
    def perform(file_set, premade_derivatives)
      service = Spot::Derivatives::PremadeDerivativeService.new(file_set)
      
      premade_derivatives.each_with_index do |derivative, index|
        service.rename_premade_derivative(derivative, index)
      end
    end
  end
end
