# frozen_string_literal: true
module Hyrax
  class FileSet
    module Derivatives
      extend ActiveSupport::Concern

      included do
        # Custom override of the corresponding Hyrax file to revert Hydra::Derivatives.output_file_service
        # to Hyrax::PersistDerivatives from Hyrax::ValkyriePersistDerivatives. The latter causes issues in
        # the current repository. This change should be able to be undone once we're Valkyrized.
        #
        # See @https://github.com/samvera/hyrax/blob/main/app/models/concerns/hyrax/file_set/derivatives.rb
        Hydra::Derivatives.source_file_service = Hyrax.config.use_valkyrie? ? Hyrax::ValkyriePersistDerivatives : Hyrax::LocalFileService
        Hydra::Derivatives.output_file_service = Hyrax::PersistDerivatives
        Hydra::Derivatives::FullTextExtract.output_file_service = Hyrax.config.use_valkyrie? ? Hyrax::ValkyriePersistDerivatives : Hyrax::PersistDirectlyContainedOutputFileService
        before_destroy :cleanup_derivatives
        # This completely overrides the version in Hydra::Works so that we
        # read and write to a local file. It's important that characterization runs
        # before derivatives so that we have a credible mime_type field to work with.
        delegate :cleanup_derivatives, :create_derivatives, to: :file_set_derivatives_service
      end

      private

      def file_set_derivatives_service
        Hyrax::DerivativeService.for(self)
      end
    end
  end
end
