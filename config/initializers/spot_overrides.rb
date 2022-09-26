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
        blacklight_config.facet_fields[Collection.collection_type_gid_document_field_name].label = :'hyrax.dashboard.my.heading.collection_type'
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

  # Define this constant, intended to be similar to AdminSet::DEFAULT_ID
  AdminSet::STUDENT_WORK_ID = Spot::StudentWorkAdminSetCreateService::ADMIN_SET_ID

  # RSolr doesn't pass :ssl options to the Faraday connection it sets up,
  # so we're adding the opts ourselves here (see line above `Faraday.new` call)
  RSolr::Client.class_eval do
    def connection
      @connection ||= begin
        conn_opts = { request: {} }
        conn_opts[:url] = uri.to_s
        conn_opts[:proxy] = proxy if proxy
        conn_opts[:request][:open_timeout] = options[:open_timeout] if options[:open_timeout]

        if options[:read_timeout] || options[:timeout]
          # read_timeout was being passed to faraday as timeout since Rsolr 2.0,
          # it's now deprecated, just use `timeout` directly.
          conn_opts[:request][:timeout] = options[:timeout] || options[:read_timeout]
        end

        conn_opts[:request][:params_encoder] = Faraday::FlatParamsEncoder
        conn_opts[:ssl] = options[:ssl].symbolize_keys if options[:ssl]

        Faraday.new(conn_opts) do |conn|
          conn.basic_auth(uri.user, uri.password) if uri.user && uri.password
          conn.response :raise_error
          conn.request :retry, max: options[:retry_after_limit], interval: 0.05,
                               interval_randomness: 0.5, backoff_factor: 2,
                               exceptions: ['Faraday::Error', 'Timeout::Error'] if options[:retry_503]
          conn.adapter options[:adapter] || Faraday.default_adapter
        end
      end
    end
  end

  # ActiveFedora's SolrService only loads config values for :url, :update_path, and :select_path,
  # so we need to update the method to include our :ssl configuration
  ActiveFedora::FileConfigurator.class_eval do
    def load_solr_config
      return @solr_config unless @solr_config.empty?
      @solr_config_path = config_path(:solr)

      ActiveFedora::Base.logger.info "ActiveFedora: loading solr config from #{::File.expand_path(@solr_config_path)}"
      begin
        config_erb = ERB.new(IO.read(@solr_config_path)).result(binding)
      rescue StandardError
        raise("solr.yml was found, but could not be parsed with ERB. \n#{$ERROR_INFO.inspect}")
      end

      begin
        solr_yml = YAML.safe_load(config_erb, [], [], true) # allow YAML aliases
      rescue StandardError
        raise("solr.yml was found, but could not be parsed.\n")
      end

      config = solr_yml.symbolize_keys
      raise "The #{ActiveFedora.environment.to_sym} environment settings were not found in the solr.yml config.  If you already have a solr.yml file defined, make sure it defines settings for the #{ActiveFedora.environment.to_sym} environment" unless config[ActiveFedora.environment.to_sym]
      config = config[ActiveFedora.environment.to_sym].deep_symbolize_keys
      @solr_config = { url: solr_url(config) }.merge(config.slice(:update_path, :select_path, :ssl))
    end
  end
end
