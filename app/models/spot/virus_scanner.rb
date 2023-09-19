# frozen_string_literal: true
require 'clamby'

module Spot
  # The ClamAV gem, which Hyrax uses for virus scanning, has been dormant
  # for ~13 years, so we're choosing to use the Clamby gem.
  #
  # @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/models/hyrax/virus_scanner.rb
  class VirusScanner < ::Hyrax::VirusScanner
    def infected?
      Clamby.virus?(file)
    end
  end
end
