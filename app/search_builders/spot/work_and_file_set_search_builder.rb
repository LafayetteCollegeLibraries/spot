# frozen_string_literal: true
#
# Adds FileSets to the list of acceptable single-item search results (used for exports)
module Spot
  class WorkAndFileSetSearchBuilder < Hyrax::WorkSearchBuilder
    private

    # @return [Array<Class>]
    def models
      super + [FileSet]
    end
  end
end
