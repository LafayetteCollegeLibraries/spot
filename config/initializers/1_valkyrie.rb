# frozen_string_literal: true
#
# Configuration for Valkyrie
Rails.application.config.after_initialize do
  # next unless Hyrax.config.use_valkyrie?

  # We're using the "Freyja" metadata adapter, included with Hyrax, as a way to migrate off of our
  # Fedora 4 instance and onto PostgreSQL (assets stored in S3): Freyja writes to Postgres and tries
  # reading from Fedora before falling over to Postgres. This requires Hyrax's "Wings" adapter
  # (specifically the ModelRegistry) to translate ActiveFedora models to Valkyrie ones.
  # That configuration has its own file.
  #
  # @see config/initializers/wings.rb
  Valkyrie::MetadataAdapter.register(Freyja::MetadataAdapter.new, :freyja)
  Valkyrie.config.metadata_adapter = :freyja

  # We're still writing to Solr for search and browsing. The indexing adapter
  # is registered in a Hyrax initializer.
  #
  # @see https://github.com/samvera/hyrax/blob/hyrax-v5.2.0/config/initializers/indexing_adapter_initializer.rb
  Valkyrie.config.indexing_adapter = :solr_index

  # Set up Valkyrie storage adapters for the LDR's object store as well as
  # IIIF and A/V derivatives.
  #
  # @see app/services/spot/derivatives/image_derivative_service.rb (:s3_iiif)
  # @see https://github.com/samvera-labs/valkyrie-shrine/
  # @note minio in development requires use to use path style s3 urls rather than hostnamed
  aws_opts = { force_path_style: !Rails.env.production? }

  Shrine.storages = {
    s3_object_store: Valkyrie::Shrine::Storage::S3.new(bucket: ENV.fetch('AWS_OBJECT_STORE_BUCKET') { 'ldr-object-store' }, **aws_opts),
    s3_iiif: Valkyrie::Shrine::Storage::S3.new(bucket: ENV.fetch('AWS_IIIF_ASSET_BUCKET') { 'iiif-derivatives' }, **aws_opts),
    s3_av: Valkyrie::Shrine::Storage::S3.new(bucket: ENV.fetch('AWS_AV_ASSET_BUCKET') { 'av-derivatives' }, **aws_opts)
  }

  # As we're using multiple buckets for different purposes (IIIF derivatives vs AV derivatives vs Object Store)
  # we'll want to utilize the `identifier_prefix` to store the intended bucket as part of the file's remote uri.
  #
  # @example prefixed remote uri
  #   iiif-shrine://<file_identifier>  #
  #
  # @note We need to use a custom PathGenerator for the valkyrie-shrine adapter, as the default one
  #       appends a uuid to the path to prevent overwrites, but as these are access derivatives, we're not
  #       particularly concerned about that.
  #
  # @see app/services/spot/s3_path.rb
  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Shrine.new(Shrine.storages[:s3_iiif], nil, Spot::S3Path::IiifPathGenerator, identifier_prefix: 'iiif'),
    :iiif_source_s3
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Shrine.new(Shrine.storages[:s3_av], nil, Spot::S3Path::AvPathGenerator, identifier_prefix: 'av'),
    :av_source_s3
  )

  if ENV['AWS_OBJECT_STORE_BUCKET'].present?
    Valkyrie::StorageAdapter.register(
      Valkyrie::Storage::VersionedShrine.new(Shrine.storages[:s3_object_store], identifier_prefix: 'obj'),
      :versioned_object_store_s3
    )
    Valkyrie.config.storage_adapter = :versioned_object_store_s3
    Rails.logger.info("Storing object assets in s3://#{ENV['AWS_OBJECT_STORE_BUCKET']}")
  else
    base_path = Rails.root.join('storage', 'files')
    Valkyrie::StorageAdapter.register(
      Valkyrie::Storage::VersionedDisk.new(
        base_path: base_path,
        file_mover: FileUtils.method(:cp)
      ),
      :disk
    )
    Valkyrie.config.storage_adapter = :disk
    Rails.logger.info("Storing object assets on disk at #{base_path}")
  end
end
