# frozen_string_literal: true
#
# Copied from Dassie example in Hyrax—register our models with Wings so they convert correctly
#
# @todo Revisit this when Valkyrizing. This might need to be moved to config/initializers/valkyrie.rb
# @see https://github.com/samvera/hyrax/blob/hyrax-v5.2.0/.dassie/config/initializers/wings.rb
Rails.application.config.after_initialize do
  Wings::ModelRegistry.register(Collection, Collection)
  Wings::ModelRegistry.register(AdminSet, AdminSet)
  Wings::ModelRegistry.register(FileSet, FileSet)
  Wings::ModelRegistry.register(Hyrax::FileSet, FileSet)
  Wings::ModelRegistry.register(Hydra::PCDM::File, Hydra::PCDM::File)
  Wings::ModelRegistry.register(Hyrax::FileMetadata, Hydra::PCDM::File)

  Wings::ModelRegistry.register(Publication, PublicationResource)
  Wings::ModelRegistry.register(Image, ImageResource)
  Wings::ModelRegistry.register(StudentWork, StudentWorkResource)
  Wings::ModelRegistry.register(AudioVisual, AudioVisualResource)
end
