# frozen_string_literal: true
#
# Set up cribbed from the Dassie example app within Hyrax, which itself is adapted from Hyku.
#
Rails.application.config.after_initialize do
  # active_fedora models we're migrating
  [Publication, Image, StudentWork, AudioVisual].each do |work_type|
    # Wings::ModelRegistry.register("#{work_type}Resource".constantize, work_type)

    # from dassie:
    #   "we register itself so we can pre-translate the class in Freyja instead of having to translate in each query_service"
    # Wings::ModelRegistry.register(work_type, work_type)

    Hyrax::ValkyrieLazyMigration.migrating("#{work_type}Resource".constantize, from: work_type)
  end

  # Map AdminSets and Collections
  Hyrax::ValkyrieLazyMigration.migrating(AdminSetResource, from: AdminSet)
  Hyrax::ValkyrieLazyMigration.migrating(CollectionResource, from: Collection)

  # Wings::ModelRegistry.register(AdminSet, AdminSet)
  # Wings::ModelRegistry.register(Collection, Collection)


  Wings::ModelRegistry.register(Hyrax::FileSet, FileSet)
  # Wings::ModelRegistry.register(FileSet, FileSet)

  Wings::ModelRegistry.register(Hyrax::FileMetadata, Hydra::PCDM::File)
  Wings::ModelRegistry.register(Hydra::PCDM::File, Hydra::PCDM::File)

  Valkyrie::MetadataAdapter.register(Freyja::MetadataAdapter.new, :freyja)
  Valkyrie.config.metadata_adapter = :freyja

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::VersionedDisk.new(
      base_path: Rails.root.join('storage', 'files'),
      file_mover: FileUtils.method(:cp)
    ),
    :disk
  )
  Valkyrie.config.storage_adapter = :disk

  Hyrax.config.query_index_from_valkyrie = true
  Hyrax.config.index_adapter = :solr_index
  Valkyrie.config.indexing_adapter = :solr_index

  # load all the sql based custom queries
  [
    Hyrax::CustomQueries::Navigators::CollectionMembers,
    Hyrax::CustomQueries::Navigators::ChildCollectionsNavigator,
    Hyrax::CustomQueries::Navigators::ParentCollectionsNavigator,
    Hyrax::CustomQueries::Navigators::ChildFileSetsNavigator,
    Hyrax::CustomQueries::Navigators::ChildWorksNavigator,
    Hyrax::CustomQueries::Navigators::FindFiles,
    Hyrax::CustomQueries::FindAccessControl,
    Hyrax::CustomQueries::FindCollectionsByType,
    Hyrax::CustomQueries::FindFileMetadata,
    Hyrax::CustomQueries::FindIdsByModel,
    Hyrax::CustomQueries::FindManyByAlternateIds,
    Hyrax::CustomQueries::FindModelsByAccess,
    Hyrax::CustomQueries::FindCountBy,
    Hyrax::CustomQueries::FindByDateRange,
    # Hyrax::CustomQueries::FindBySourceIdentifier  # from bulkrax
  ].each do |handler|
    Hyrax.query_service.services[0].custom_queries.register_query_handler(handler)
  end
end

Rails.application.config.to_prepare do
  AdminSetResource.class_eval do

  end

  CollectionResource.class_eval do
    attribute :internal_resource, Valkyrie::Types::Any.default('Collection'), internal: true
  end

  # Copied from
  Valkyrie.config.resource_class_resolver = lambda do |resource_klass_name|
    klass_name = resource_klass_name.gsub(/^Wings\((.+)\)$/, '\1')
    klass_name = klass_name.gsub(/Resource$/, '')
    resource_types = Hyrax.config.curation_concerns.map(&:to_s).concat(['Collection', 'AdminSet'])

    if resource_types.include?(klass_name)
      "#{klass_name}Resource".constantize
    elsif 'Collection' == klass_name
      CollectionResource
    elsif 'AdminSet' == klass_name
      AdminSetResource
      # Without this mapping, we'll see cases of Postgres Valkyrie adapter attempting to write to
      # Fedora.  Yeah!
    elsif 'Hydra::AccessControl' == klass_name
      Hyrax::AccessControl
    elsif 'FileSet' == klass_name
      Hyrax::FileSet
    elsif 'Hydra::AccessControls::Embargo' == klass_name
      Hyrax::Embargo
    elsif 'Hydra::AccessControls::Lease' == klass_name
      Hyrax::Lease
    elsif 'Hydra::PCDM::File' == klass_name
      Hyrax::FileMetadata
    else
      klass_name.constantize
    end
  end
end
