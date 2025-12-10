# frozen_string_literal: true
#
# Copied from Dassie example in Hyrax—register our models with Wings so they convert correctly
#
# @todo Revisit this when Valkyrizing. This might need to be moved to config/initializers/valkyrie.rb
# @see https://github.com/samvera/hyrax/blob/hyrax-v5.2.0/.dassie/config/initializers/wings.rb
Rails.application.config.after_initialize do
  Wings::ModelRegistry.register(CollectionResource, Collection)
  Wings::ModelRegistry.register(AdminSetResource, AdminSet)
  Wings::ModelRegistry.register(FileSet, FileSet)
  Wings::ModelRegistry.register(Hyrax::FileSet, FileSet)
  Wings::ModelRegistry.register(Hydra::PCDM::File, Hydra::PCDM::File)
  Wings::ModelRegistry.register(Hyrax::FileMetadata, Hydra::PCDM::File)

  Wings::ModelRegistry.register(PublicationResource, Publication)
  Wings::ModelRegistry.register(ImageResource, Image)
  Wings::ModelRegistry.register(StudentWorkResource, StudentWork)
  Wings::ModelRegistry.register(AudioVisualResource, AudioVisual)
end
