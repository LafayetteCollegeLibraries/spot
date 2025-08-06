# frozen_string_literal: true
require 'wings'
require 'shrine/storage/s3'

Hyrax.config do |config|
  config.register_curation_concern :publication, :image, :student_work, :audio_visual

  # Can't define this within the Bulkrax initializer as it runs _before_ this
  Bulkrax.default_work_type = Hyrax.config.curation_concerns.first.name

  # Wings provides a method for converting a Hyrax::Resource-based object to an
  # ActiveFedora model equivalent (note: this isn't a true one-for-one, the object's
  # properties are copied to a new instance of the registered model).
  #
  # @example converting a Hyrax::Resource object to an ActiveFedora one
  #   work = Image.find('abc123def')
  #   resource = work.valkyrie_resource
  #   #=> #<ImageResource id=#<Valkyrie::ID:0x0000ffff6d18c870 @id="abc123def"> internal_resource=...>
  #
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/lib/wings/valkyrizable.rb
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/lib/wings/model_transformer.rb
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/lib/wings/model_registry.rb
  Wings::ModelRegistry.register(PublicationResource, Publication)
  Wings::ModelRegistry.register(ImageResource, Image)
  Wings::ModelRegistry.register(StudentWorkResource, StudentWork)
  Wings::ModelRegistry.register(AudioVisualResource, AudioVisual)

  # @note adding routes for the resources helped with some test issues, but doesn't seem to be the
  #       standard for configuration.
  # config.register_curation_concern :publication_resource, :image_resource, :student_work_resource, :audio_visual_resource

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

  # The end-goal is to use the new Hyrax models for AdminSets and Collections,
  # but as of Hyrax 4.0 it's recommended to leave these as the older ones.
  # I think Hyrax > 5.0 is when the new models come into play.
  config.admin_set_model = '::AdminSet' # 'Hyrax::AdministrativeSet'
  config.collection_model = '::Collection' # 'Hyrax::PcdmCollection'
  # config.file_set_model = '::FileSet'
  # config.index_adapter = :solr_index
  # config.query_index_from_valkyrie = true

  # GET query strings have a character limit and Solr has _very_ long queries, so use POST
  config.solr_default_method = :post

  # Hyrax determines which derivative_service to run on a FileSet by choosing which
  # of these defined services are #valid?. Best recommended to add to this array
  # by putting the narrower (re: mime_type) services to the top and the more broad ones
  # towards the end, with Hyrax::FileSetDerivativesService acting as a catch-all for
  # anything that may slip through the cracks.
  #
  # For old Hyrax implementation, still used in Hyrax 4.0:
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/jobs/create_derivatives_job.rb
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/models/concerns/hyrax/file_set/derivatives.rb
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/services/hyrax/derivative_service.rb
  #
  # For newer Valkyrie implementation:
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/jobs/valkyrie_create_derivatives_job.rb#L10
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/services/hyrax/file_set_derivatives_service.rb
  config.derivative_services = [
    Spot::Derivatives::ImageDerivativeService,
    Spot::Derivatives::AudioDerivativeService,
    Spot::Derivatives::VideoDerivativeService,
    Spot::Derivatives::BaseDerivativeService,
    ::Hyrax::FileSetDerivativesService
  ]

  # Email recipient of messages sent via the contact form
  config.contact_email = "dss@lafayette.edu"

  # Text prefacing the subject entered in the contact form
  config.subject_prefix = "LDR Contact form:"

  # If you have ffmpeg installed and want to transcode audio and video set to true
  config.enable_ffmpeg = true

  # Path to the file characterization tool
  config.fits_path = ENV.fetch('FITS_PATH') { 'fits.sh' }

  # Path to the file derivatives creation tool
  config.libreoffice_path = ENV.fetch('SOFFICE_PATH') { 'soffice' }

  # Stream realtime notifications to users in the browser
  config.realtime_notifications = false

  # Location autocomplete uses geonames to search for named regions
  # Username for connecting to geonames
  config.geonames_username = 'lafayette_dss'

  # Should work creation require file upload, or can a work be created first
  # and a file added at a later time?
  # The default is true.
  config.work_requires_files = true

  # Enable IIIF service
  # @todo not sure if this is necessary if we're no longer running RIIIF? I'm presuming
  #       that this is more of a switch for "does this repository support a IIIF viewer?"
  config.iiif_image_server = true

  # Returns a URL that resolves to an image provided by a IIIF image server
  config.iiif_image_url_builder = Spot::IiifService.method(:image_url)

  # Returns a URL that resolves to an info.json file provided by a IIIF image server
  config.iiif_info_url_builder = Spot::IiifService.method(:info_url)

  # Returns a URL that indicates your IIIF image server compliance level
  config.iiif_image_compliance_level_uri = Spot::IiifService::COMPLIANCE_LEVEL_URI

  # Returns a IIIF image size default
  config.iiif_image_size_default = Spot::IiifService::DEFAULT_SIZE

  # Fields to display in the IIIF metadata section
  config.iiif_metadata_fields = %i[
    title subtitle title_alternative creator contributor date date_issued
    abstract description inscription subject_label subject_ocm keyword language_label
    location_label standard_identifier rights_holder rights_statement_label
  ]

  # This user is logged as the acting user for jobs and other processes that
  # run without being attributed to a specific user (e.g. creation of the
  # default admin set).
  config.system_user_key = 'repository@lafayette.edu'

  # The user who runs batch jobs. Update this if you aren't using emails
  config.batch_user_key = 'dss@lafayette.edu'

  # The user who runs fixity check jobs. Update this if you aren't using emails
  # config.audit_user_key = 'audituser@example.com'

  # The banner image. Should be 5000px wide by 1000px tall
  config.banner_image = '/assets/skillman-banner.jpg'

  # Temporary paths to hold uploads before they are ingested into FCrepo
  # These must be lambdas that return a Pathname. Can be configured separately
  config.upload_path = ->() { Pathname.new(ENV.fetch('HYRAX_UPLOAD_PATH', Rails.root.join('tmp', 'uploads'))) }
  config.cache_path = ->() { Pathname.new(ENV.fetch('HYRAX_CACHE_PATH', Rails.root.join('tmp', 'cache'))) }

  # Location on local file system where derivatives will be stored
  # If you use a multi-server architecture, this MUST be a shared volume
  config.derivatives_path = Pathname.new(ENV.fetch('HYRAX_DERIVATIVES_PATH', Rails.root.join('tmp', 'derivatives')))

  # Location on local file system where uploaded files will be staged
  # prior to being ingested into the repository or having derivatives generated.
  # If you use a multi-server architecture, this MUST be a shared volume.
  config.working_path = Pathname.new(ENV.fetch('HYRAX_UPLOAD_PATH', Rails.root.join('tmp', 'uploads')))

  # A configuration point for changing the behavior of the rights statement service.
  config.rights_statement_service_class = Spot::RightsStatementService

  # ActiveJob queue to handle ingest-like jobs
  config.ingest_queue_name = :ingest

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      Rails.logger.warn "BrowseEverything is not installed"
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end

  config.branding_path = ENV.fetch('HYRAX_COLLECTION_BRANDING_PATH', Rails.root.join('public', 'branding'))
end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"
