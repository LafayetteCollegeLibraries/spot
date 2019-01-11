# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightRangeLimit::ControllerOverride
  include BlacklightAdvancedSearch::Controller
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def self.uploaded_field
    # solr_name('system_create', :stored_sortable, type: :date)
    'system_create_dtsi'
  end

  def self.modified_field
    # solr_name('system_modified', :stored_sortable, type: :date)
    'system_modified_dtsi'
  end

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = Spot::CatalogSearchBuilder

    # Show gallery view
    config.view.gallery.partials = [:index_header, :index]
    config.view.slideshow.partials = [:index]

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      qf: 'title_tesim description_tesim creator_tesim keyword_tesim'
    }

    # solr field configuration for document/show views
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display

    # config.add_facet_field 'human_readable_type_sim', label: "Type", limit: 5
    config.add_facet_field 'member_of_collections_ssim',
                           label: I18n.t('blacklight.search.fields.member_of_collections'),
                           limit: 5
    config.add_facet_field 'resource_type_ssim',
                           label: I18n.t('blacklight.search.fields.resource_type'),
                           limit: 5
    config.add_facet_field 'creator_sim',
                           label: I18n.t('blacklight.search.fields.creator'),
                           limit: 5
    config.add_facet_field 'contributor_sim',
                           label: I18n.t('blacklight.search.fields.contributor'),
                           limit: 5
    config.add_facet_field 'keyword_sim',
                           label: I18n.t('blacklight.search.fields.keyword'),
                           limit: 5
    config.add_facet_field 'subject_sim',
                           label: I18n.t('blacklight.search.fields.subject'),
                           limit: 5
    config.add_facet_field 'academic_department_sim',
                           label: I18n.t('blacklight.search.fields.academic_department'),
                           limit: 5
    # config.add_facet_field solr_name("language", :facetable), limit: 5
    # config.add_facet_field solr_name("place_label", :facetable), limit: 5
    config.add_facet_field 'publisher_sim',
                           label: I18n.t('blacklight.search.fields.publisher'),
                           limit: 5

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
                           label: I18n.t('blacklight.search.fields.title'),
                           itemprop: 'name',
                           if: false
    config.add_index_field 'resource_type_ssim',
                           label: I18n.t('blacklight.search.fields.resource_type'),
                           itemprop: 'resourceType',
                           link_to_search: 'resource_type_ssim'
    config.add_index_field 'academic_department_ssim',
                           label: I18n.t('blacklight.search.fields.academic_department'),
                           itemprop: 'department',
                           link_to_search: 'department_sim'
    config.add_index_field 'keyword_tesim',
                           label: I18n.t('blacklight.search.fields.keyword'),
                           itemprop: 'keywords',
                           link_to_search: 'keyword_sim'
    config.add_index_field 'subject_tesim',
                           label: I18n.t('blacklight.search.fields.subject'),
                           itemprop: 'about',
                           link_to_search: 'subject_sim'
    config.add_index_field 'creator_tesim',
                           label: I18n.t('blacklight.search.fields.creator'),
                           itemprop: 'creator',
                           link_to_search: 'creator_sim'
    config.add_index_field 'contributor_tesim',
                           label: I18n.t('blacklight.search.fields.contributor'),
                           itemprop: 'contributor',
                           link_to_search: 'contributor_sim'
    # config.add_index_field solr_name("proxy_depositor", :symbol), label: "Depositor", helper_method: :link_to_profile
    config.add_index_field 'depositor_tesim',
                           label: I18n.t('blacklight.search.fields.depositor'),
                           helper_method: :link_to_profile
    config.add_index_field 'publisher_tesim',
                           label: I18n.t('blacklight.search.fields.publisher'),
                           itemprop: 'publisher',
                           link_to_search: 'publisher_sim'
    # config.add_index_field solr_name("place_label", :stored_searchable), itemprop: 'contentLocation', link_to_search: solr_name("place_label", :facetable)
    config.add_index_field 'language_tesim',
                           label: I18n.t('blacklight.search.fields.language'),
                           itemprop: 'inLanguage',
                           link_to_search: 'language_sim'
    config.add_index_field 'date_modified_dtsi',
                           label: I18n.t('blacklight.search.fields.date_modified'),
                           itemprop: 'dateModified',
                           helper_method: :human_readable_date
    # config.add_index_field solr_name("date_created", :stored_searchable), itemprop: 'dateCreated'
    config.add_index_field 'rights_statement_tesim',
                           label: I18n.t('blacklight.search.fields.rights_statement'),
                           helper_method: :rights_statement_links
    config.add_index_field 'license_tesim',
                           label: I18n.t('blacklight.search.fields.license'),
                           helper_method: :license_links
    # config.add_index_field solr_name("file_format", :stored_searchable), link_to_search: solr_name("file_format", :facetable)
    config.add_index_field 'identifier_tesim',
                           label: I18n.t('blacklight.search.fields.identifier'),
                           helper_method: :index_field_link,
                           field_name: 'identifier'
    config.add_index_field 'embargo_release_date_dtsi',
                           label: 'Embargo release date',
                           helper_method: :human_readable_date
    config.add_index_field 'lease_expiration_date_dtsi',
                           label: 'Lease expiration date',
                           helper_method: :human_readable_date

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = solr_name("title", :stored_searchable)
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_timv",
        pf: title_name.to_s
      }
    end

    config.add_search_field('title', label: 'Title') do |field|
      field.solr_parameters = {
        qf: '$title_qf',
        pf: '$title_pf'
      }
    end

    config.add_search_field('author', label: 'Author') do |field|
      field.solr_parameters = {
        qf: '$author_qf',
        pf: '$author_pf'
      }
    end

    config.add_search_field('subject', label: 'Subject') do |field|
      field.solr_parameters = {
        qf: '$subject_qf',
        pf: '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance"
    config.add_sort_field "#{uploaded_field} desc", label: "date uploaded \u25BC"
    config.add_sort_field "#{uploaded_field} asc", label: "date uploaded \u25B2"
    config.add_sort_field "#{modified_field} desc", label: "date modified \u25BC"
    config.add_sort_field "#{modified_field} asc", label: "date modified \u25B2"

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
