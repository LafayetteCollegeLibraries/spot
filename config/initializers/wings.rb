# frozen_string_literal: true
#
# Set up cribbed from the Dassie example app within Hyrax, which itself is adapted from Hyku.
#
Rails.application.config.after_initialize do
  # active_fedora models we're migrating
  [Publication, Image, StudentWork, AudioVisual].each do |work_type|
    # ValkyrieLazyMigration sets up connections between an AF-based work_type and its Valkyrized equivalent
    # and also registers the connection in the Wings::ModelRegistry
    Hyrax::ValkyrieLazyMigration.migrating("#{work_type}Resource".constantize, from: work_type)

    # from dassie:
    #   "we register itself so we can pre-translate the class in Freyja instead of having to translate in each query_service"
    Wings::ModelRegistry.register(work_type, work_type)
  end

  # Map AdminSets and Collections
  Hyrax::ValkyrieLazyMigration.migrating(AdminSetResource, from: ::AdminSet)
  Hyrax::ValkyrieLazyMigration.migrating(CollectionResource, from: ::Collection)

  Wings::ModelRegistry.register(AdminSet, AdminSet)
  Wings::ModelRegistry.register(Collection, Collection)
  Wings::ModelRegistry.register(FileSet, FileSet)

  Wings::ModelRegistry.register(Hyrax::FileSet, FileSet)
  Wings::ModelRegistry.register(Hyrax::FileMetadata, Hydra::PCDM::File)
  Wings::ModelRegistry.register(Hydra::PCDM::File, Hydra::PCDM::File)

  ##
  #  ADAPTERS SETUP
  #  metadata, indexing, storage
  ##

  Valkyrie::MetadataAdapter.register(Freyja::MetadataAdapter.new, :freyja)
  Valkyrie.config.metadata_adapter = :freyja
  Hyrax.config.query_index_from_valkyrie = true
  Hyrax.config.index_adapter = :solr_index

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::VersionedDisk.new(
      base_path: Rails.root.join('storage', 'files'),
      file_mover: FileUtils.method(:cp)
    ),
    :disk
  )
  Valkyrie.config.storage_adapter = :disk
  Valkyrie.config.indexing_adapter = :solr_index

  # Use valkyrie-shrine's s3 capabilities to store iiif source images as a way
  # to use more Samvera-community code rather than rolling our own AWS client usage.
  #
  # @see app/services/spot/derivatives/image_derivative_service.rb (:s3_iiif)
  # @see https://github.com/samvera-labs/valkyrie-shrine/
  aws_opts = { force_path_style: !Rails.env.production? }

  Shrine.storages = {
    s3_iiif: Shrine::Storage::S3.new(bucket: ENV.fetch('AWS_IIIF_ASSET_BUCKET'), **aws_opts),
    s3_av: Shrine::Storage::S3.new(bucket: ENV.fetch('AWS_AV_ASSET_BUCKET'), **aws_opts)
  }

  # @note We need to use a custom PathGenerator for the valkyrie-shrine adapter, as the default one
  #       appends a uuid to the path to prevent overwrites, but as these are access derivatives, we're not
  #       particularly concerned about that.
  #
  # @see app/services/spot/s3_path.rb
  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Shrine.new(Shrine.storages[:s3_iiif], nil, Spot::S3Path::IiifPathGenerator),
    :iiif_source_s3
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Shrine.new(Shrine.storages[:s3_av], nil, Spot::S3Path::AvPathGenerator),
    :av_source_s3
  )

  # The :solr_index adapter is set up in a Hyrax initializer, so we just need to ensure
  # that Hyrax and Valkyrie are configured to use it
  #
  # @see https://github.com/samvera/hyrax/blob/hyrax-v5.2.0/config/initializers/indexing_adapter_initializer.rb
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
    Hyrax::CustomQueries::FindBySourceIdentifier # from bulkrax
  ].each do |handler|
    Hyrax.query_service.services[0].custom_queries.register_query_handler(handler)
  end
end

Rails.application.config.to_prepare do
  # Copied from Dassie but modified to map our CurationConcern work types to Hyrax::Resource classes
  Valkyrie.config.resource_class_resolver = lambda do |resource_klass_name|
    resource_types = Hyrax.config.curation_concerns.map(&:to_s).concat(['Collection', 'AdminSet'])

    klass_name = resource_klass_name.gsub(/^Wings\((.+)\)$/, '\1')
    klass_name = klass_name.gsub(/Resource$/, '')

    if resource_types.include?(klass_name)
      "#{klass_name}Resource".constantize
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
