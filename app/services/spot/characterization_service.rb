# frozen_string_literal: true
module Spot
  # Subclassing hydra-works' CharacterizationService to automatically default
  # to the :fits_servlet service if a URL is present as an environment variable.
  # Previously, I was copy-pasting Hyrax's CharacterizeJob in order to stuff the
  # :fits_servlet option (see: https://github.com/LafayetteCollegeLibraries/spot/blob/2022.5/app/jobs/characterize_job.rb),
  # but the latest Hyrax code allows setting a characterization service within the job.
  #
  # @see config/initializers/spot_overrides.rb
  class CharacterizationService < ::Hydra::Works::CharacterizationService
    def self.run(characterization_proxy, filepath, opts = {})
      tool = ENV['FITS_SERVLET_URL'].present? ? :fits_servlet : :fits
      opts = { ch12n_tool: tool }.merge(opts)

      super(characterization_proxy, filepath, opts)
    end
  end
end
