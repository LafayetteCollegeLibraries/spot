# frozen_string_literal: true
#
# Class attribute updates + monkey-patching required to get Hyrax/etc
# acting like we'd like them to. Try to leave some comments to help
# yourself out. Sincerely, you from the future.
Rails.application.config.to_prepare do
  # Spot overrides Hyrax
  Hyrax::Dashboard::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::Dashboard::CollectionsController.form_class = Spot::Forms::CollectionForm
  Hyrax::Dashboard::CollectionsController.include Spot::CollectionsControllerBehavior

  Hyrax::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::CollectionsController.include Spot::CollectionsControllerBehavior

  Hyrax::DerivativeService.services = [
    ::Spot::PdfDerivativesService,
    ::Spot::ImageDerivativesService,
    ::Hyrax::FileSetDerivativesService
  ]

  Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CollectionsMembershipActor, Spot::Actors::CollectionsMembershipActor)

  Hyrax::ContactFormController.class_eval { layout 'hyrax/1_column' }
  Hyrax::PagesController.class_eval { layout 'hyrax/1_column' }

  # the dashboard/my/collections (+ thus, dashboard/collections) controller defines
  # blacklight facets + uses I18n.t to provide a label. as we've found from past experience,
  # this can get called _before_ all of the locales are loaded, resulting in a
  # "translation missing" message being provided as a fall-back label. this should
  # prevent that error from appearing by replacing the +translate+ calls with a symbolized
  # I18n key (see also 0717dee, + catalog_controller.rb)
  [Hyrax::My::CollectionsController, Hyrax::Dashboard::CollectionsController].each do |klass|
    klass.class_eval do
      def self.update_facet_labels!
        blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
        blacklight_config.facet_fields[Hyrax.config.collection_type_index_field].label = :'hyrax.dashboard.my.heading.collection_type'
        blacklight_config.facet_fields['has_model_ssim'].label = :'hyrax.dashboard.my.heading.collection_type'
      end
      update_facet_labels!
    end
  end

  # same as previous: updating facet labels for dashboard works controller
  [Hyrax::My::WorksController, Hyrax::Dashboard::WorksController].each do |klass|
    klass.class_eval do
      def self.update_facet_labels!
        blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
      end
      update_facet_labels!
    end
  end

  # We're using an older version of the FITSServlet tool (1.1.3 as of 2019-12-03,
  # anything higher throws an exception that I can't nail down) that predates
  # a change to set the response encoding to UTF-8. So we need to do this as
  # early as possible within the Characterization tool.
  require 'hydra-file_characterization'

  Hydra::FileCharacterization::Characterizers::FitsServlet.class_eval do
    # Wrap the datafile= param in quotes to handle filenames with spaces
    def command
      %(curl -k -F datafile=@"#{filename}" #{ENV['FITS_SERVLET_URL']}/examine)
    end

    def output
      super.encode('UTF-8', invalid: :replace)
    end
  end

  # Add our SolrSuggestActor to the front of the default actor-stack. This will
  # trigger a build of all of the Solr suggestion dictionaries at the end of
  # each create, update, destroy process (each method calls the next actor and _then_
  # enqueues the job).
  Hyrax::CurationConcern.actor_factory.unshift(SolrSuggestActor)

  # By default, +Hydra::AccessControls::Embargo#active?+ compares the
  # embargo_release_date (a DateTime) to +Date.today+ (a Date). When
  # the release date is the same day as today, we'll get a truthy return value
  # when it should be falsey.
  #
  #   Date.today < DateTime.parse(Date.today.to_s)
  #   # => true
  #
  #   DateTime.parse(Date.today.to_s) < DateTime.parse(Date.today.to_s)
  #   # => false
  #
  # @see https://github.com/samvera/hydra-head/blob/v10.7.0/hydra-access-controls/app/models/hydra/access_controls/embargo.rb#L13-L15
  Hydra::AccessControls::Embargo.class_eval do
    def active?
      embargo_release_date.present? && DateTime.current < embargo_release_date
    end
  end

  Hydra::AccessControls::Lease.class_eval do
    def active?
      lease_expiration_date.present? && DateTime.current < lease_expiration_date
    end
  end

  # Updating how SimpleForm generates labels so that we can use the same locales
  # for the form as those for the metadata display.
  SimpleForm::Inputs::Base.class_eval do
    protected def raw_label_text
      options[:label] || I18n.t("blacklight.search.fields.#{attribute_name}", default: label_translation)
    end
  end

  # Adding label support for metadata-only records
  Hyrax::PermissionBadge.class_eval do
    old_visibility_label_class = Hyrax::PermissionBadge::VISIBILITY_LABEL_CLASS.dup
    remove_const(:VISIBILITY_LABEL_CLASS) if const_defined?(:VISIBILITY_LABEL_CLASS)
    const_set(:VISIBILITY_LABEL_CLASS, old_visibility_label_class.tap { |h| h[:metadata] = 'label-info' }.freeze)
  end

  Bulkrax::CsvParser.class_eval do
    def records(_opts = {})
      return @records if @records.present?

      client = Aws::S3::Client.new()
      file_for_import = only_updates ? parser_fields['partial_import_file_path'] : import_file_path
      resp = client.get_object(response_target: '/spot/tmp/import/'+file_for_import, bucket: 'bulkrax-imports', key: file_for_import)
      # data for entry does not need source_identifier for csv, because csvs are read sequentially and mapped after raw data is read.
      csv_data = entry_class.read_data('/spot/tmp/import/'+file_for_import)
      importer.parser_fields['total'] = csv_data.count
      importer.save

      @records = csv_data.map { |record_data| entry_class.data_for_entry(record_data, nil, self) }
    end
  end

  # Define this constant, intended to be similar to AdminSet::DEFAULT_ID
  AdminSet::STUDENT_WORK_ID = Spot::StudentWorkAdminSetCreateService::ADMIN_SET_ID

  # Override the Browse-Everything Retreiver to take S3 URIs
  BrowseEverything::Retriever.prepend(Spot::RetrievesS3Urls)

  BrowseEverything::Retriever.class_eval do
    class << self
      prepend Spot::RetrievesS3Urls::ClassMethods
    end
  end

  # Our own Characterization Service subclass that uses :fits_servlet by default
  CharacterizeJob.characterization_service = Spot::CharacterizationService

  # Override the Browse-Everything Retreiver to take S3 URIs
  BrowseEverything::Retriever.prepend(Spot::RetrievesS3Urls)
  BrowseEverything::Retriever.class_eval do
    class << self
      prepend Spot::RetrievesS3Urls::ClassMethods
    end
  end

  Bulkrax::ExportBehavior.class_eval do
    # Prepend the file_set id to ensure a unique filename and also one that is not longer than 255 characters
    def filename(file_set)
      return if file_set.original_file.blank?
      fn = file_set.original_file.file_name.first
      mime = ::Marcel::MimeType.for(file_set.original_file.mime_type)
      ext_mime = ::Marcel::MimeType.for(file_set.original_file.file_name)
      filename = "#{fn}.#{mime.to_sym}"
      filename = fn.to_s if mime.to_s == ext_mime.to_s
      # Remove extention truncate and reattach
      ext = File.extname(filename)
      "#{File.basename(filename, ext)[0...(220 - ext.length)]}#{ext}"
    end
  end

  Bulkrax::CsvEntry.class_eval do
    def build_files_metadata
      # attaching files to the FileSet row only so we don't have duplicates when importing to a new tenant
      if hyrax_record.work?
        build_thumbnail_files
      end

      file_mapping = key_for_export('file')
      file_sets = hyrax_record.file_set? ? Array.wrap(hyrax_record) : hyrax_record.file_sets
      filenames = map_file_sets(file_sets)

      handle_join_on_export(file_mapping, filenames, mapping['file']&.[]('join')&.present?)
    end
  end

  Bulkrax::CsvParser.prepend(Spot::SpotCsvParser)
end
