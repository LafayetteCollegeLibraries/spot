# frozen_string_literal: true
module Spot
  module Derivatives
    # Abstract class that other derivative services can inherit from
    class BaseDerivativesService
      attr_reader :file_set

      def initialize(file_set)
        @file_set = file_set
      end

      def cleanup_derivatives
        raise NotImplementedError, '#create_derivatives should be implemented by a child class of BaseDerivativesService'
      end

      def create_derivatives(_filename)
        raise NotImplementedError, '#create_derivatives should be implemented by a child class of BaseDerivativesService'
      end
    end
  end
end
