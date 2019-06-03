# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightRangeLimit::ControllerOverride
  include BlacklightAdvancedSearch::Controller
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    config.view.gallery.partials = [:index_header, :index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = Spot::CatalogSearchBuilder

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      qf: 'title_tesim description_tesim creator_tesim keyword_tesim all_text_timv'
    }

    # solr field configuration for document/show views
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display

    # config.add_facet_field 'human_readable_type_sim', label: "Type", limit: 5
    config.add_facet_field 'member_of_collections_ssim',
                           label: I18n.t('blacklight.search.fields.member_of_collection'),
                           limit: 5
    config.add_facet_field 'resource_type_sim',
                           label: I18n.t('blacklight.search.fields.resource_type'),
                           limit: 5
    config.add_facet_field 'creator_sim',
                           label: I18n.t('blacklight.search.fields.creator'),
                           limit: 5
    config.add_facet_field 'publisher_sim',
                           label: I18n.t('blacklight.search.fields.publisher'),
                           limit: 5
    config.add_facet_field 'organization_sim',
                           label: I18n.t('blacklight.search.fields.organization'),
                           limit: 5
    config.add_facet_field 'division_sim',
                           label: I18n.t('blacklight.search.fields.division'),
                           limit: 5
    config.add_facet_field 'academic_department_sim',
                           label: I18n.t('blacklight.search.fields.academic_department'),
                           limit: 5
    config.add_facet_field 'subject_sim',
                           label: I18n.t('blacklight.search.fields.subject'),
                           limit: 5
    config.add_facet_field 'keyword_sim',
                           label: I18n.t('blacklight.search.fields.keyword'),
                           limit: 5
    config.add_facet_field 'language_label_ssim',
                           label: I18n.t('blacklight.search.fields.language'),
                           limit: 5
    config.add_facet_field 'location_label_ssim',
                           label: I18n.t('blacklight.search.fields.location'),
                           limit: 5
    config.add_facet_field 'years_encompassed_iim',
                           include_in_advanced_search: false,
                           label: I18n.t('blacklight.search.fields.years_encompassed'),
                           range: true

    #
    # admin facets
    #
    config.add_facet_field 'depositor_ssim',
                           label: I18n.t('blacklight.search.fields.depositor'),
                           limit: 5,
                           admin: true
    config.add_facet_field 'proxy_depositor_ssim',
                           label: I18n.t('blacklight.search.fields.proxy_depositor'),
                           limit: 5,
                           admin: true
    config.add_facet_field 'admin_set_sim',
                           label: I18n.t('blacklight.search.fields.admin_set'),
                           limit: 5,
                           admin: true

    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field 'generic_type_sim', if: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'title_tesim',
                           itemprop: 'name',
                           if: false
    config.add_index_field 'resource_type_ssim',
                           itemprop: 'resourceType',
                           label: I18n.t('blacklight.search.fields.resource_type'),
                           link_to_search: 'resource_type_ssim'
    config.add_index_field 'academic_department_tesim',
                           itemprop: 'department',
                           label: I18n.t('blacklight.search.fields.academic_department'),
                           link_to_search: 'academic_department_sim'
    config.add_index_field 'keyword_tesim',
                           itemprop: 'keywords',
                           label: I18n.t('blacklight.search.fields.keyword'),
                           link_to_search: 'keyword_sim'
    config.add_index_field 'subject_tesim',
                           itemprop: 'about',
                           label: I18n.t('blacklight.search.fields.subject'),
                           link_to_search: 'subject_sim'
    config.add_index_field 'creator_tesim',
                           itemprop: 'creator',
                           label: I18n.t('blacklight.search.fields.creator'),
                           link_to_search: 'creator_sim'
    config.add_index_field 'contributor_tesim',
                           itemprop: 'contributor',
                           label: I18n.t('blacklight.search.fields.contributor'),
                           link_to_search: 'contributor_sim'
    config.add_index_field 'publisher_tesim',
                           itemprop: 'publisher',
                           label: I18n.t('blacklight.search.fields.publisher'),
                           link_to_search: 'publisher_sim'
    config.add_index_field 'language_label_ssim',
                           itemprop: 'inLanguage',
                           label: I18n.t('blacklight.search.fields.language'),
                           link_to_search: 'language_sim'
    config.add_index_field 'date_issued_ssim',
                           label: I18n.t('blacklight.search.fields.date_issued')
    config.add_index_field 'rights_statement_tesim',
                           helper_method: :rights_statement_links,
                           label: I18n.t('blacklight.search.fields.rights_statement')
    config.add_index_field 'license_tesim',
                           helper_method: :license_links,
                           label: I18n.t('blacklight.search.fields.license')
    config.add_index_field 'embargo_release_date_dtsi',
                           label: 'Embargo release date',
                           helper_method: :human_readable_date
    config.add_index_field 'lease_expiration_date_dtsi',
                           label: 'Lease expiration date',
                           helper_method: :human_readable_date

    #
    # search field configuration
    #
    config.add_search_field('all_fields', label: I18n.t('blacklight.search.fields.all_fields')) do |field|
      fields = %w[
        all_fields_search_timv
        english_language_date_teim
        file_format_tesim
        all_text_timv
      ]

      field.solr_parameters = {
        qf: fields.join(' '),
        pf: 'all_text_timv'
      }
    end

    config.add_search_field('title', label: I18n.t('blacklight.search.fields.title')) do |field|
      fields = %w[
        title_tesim^2
        subtitle_tesim
        title_alternative_tesim
      ]

      field.solr_parameters = {
        qf: fields.join(' '),
        pf: 'title_tesim'
      }
    end

    config.add_search_field('author', label: I18n.t('blacklight.search.fields.author')) do |field|
      fields = %w[
        creator_tesim
        contributor_tesim
        editor_tesim
      ]

      field.solr_parameters = {
        qf: fields.join(' '),
        pf: 'creator_tesim'
      }
    end

    config.add_search_field('subject', label: I18n.t('blacklight.search.fields.subject')) do |field|
      field.solr_parameters = {
        qf: 'subject_tesim',
        pf: ''
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field 'score desc, system_create_dtsi desc', label: I18n.t('blacklight.sort.fields.relevance')
    config.add_sort_field 'date_issued_sort_dtsi asc', label: I18n.t('blacklight.sort.fields.date_issued.asc')
    config.add_sort_field 'date_issued_sort_dtsi desc', label: I18n.t('blacklight.sort.fields.date_issued.desc')
    config.add_sort_field 'system_create_dtsi asc', label: I18n.t('blacklight.sort.fields.date_added.asc')
    config.add_sort_field 'system_create_dtsi desc', label: I18n.t('blacklight.sort.fields.date_added.desc')

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end
end
