# frozen_string_literal: true
#
# Provides the configuration for our searches within Solr (via Blacklight).
#
# @see https://github.com/projectblacklight/blacklight/wiki/Blacklight-configuration
class CatalogController < ApplicationController
  include BlacklightRangeLimit::ControllerOverride
  include BlacklightAdvancedSearch::Controller
  include BlacklightOaiProvider::Controller
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
      qf: 'title_tesim description_tesim creator_tesim keyword_tesim extracted_text_tsimv',

      'hl.simple.pre': '<strong>',
      'hl.tag.pre': '<strong>',
      'hl.simple.post': '</strong>',
      'hl.tag.post': '</strong>',
      'hl.method': 'fastVector',
      'hl.snippets': 5
    }

    # solr field configuration for document/show views
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # @note: when defining a field (facet, index, show, search), define the
    #        +:label+ option as a Symbol that refers to the field _without_
    #        the "solr jargon" (ex. "_tesim", "_ssim", etc) suffix. it _needs_
    #        to be a Symbol in order for +I18n.translate+ to use it as
    #        a fall-back when the lookup with the "solr jargon" ultimately fails.
    #        this will save us from having to provide multiple locale definitions
    #        for each attribute.
    #
    #        @example
    #          config.add_index_field('keyword_ssim', label: :'blacklight.search.fields.keyword')

    # config.add_facet_field 'human_readable_type_sim', label: "Type", limit: 5
    config.add_facet_field 'member_of_collections_ssim',
                           label: :'blacklight.search.fields.member_of_collection',
                           limit: 5
    config.add_facet_field 'resource_type_sim',
                           label: :'blacklight.search.fields.resource_type',
                           limit: 5
    config.add_facet_field 'creator_sim',
                           label: :'blacklight.search.fields.creator',
                           limit: 5
    config.add_facet_field 'publisher_sim',
                           label: :'blacklight.search.fields.publisher',
                           limit: 5
    config.add_facet_field 'organization_sim',
                           label: :'blacklight.search.fields.organization',
                           limit: 5
    config.add_facet_field 'division_sim',
                           label: :'blacklight.search.fields.division',
                           limit: 5
    config.add_facet_field 'academic_department_sim',
                           label: :'blacklight.search.fields.academic_department',
                           limit: 5
    config.add_facet_field 'subject_label_ssim',
                           label: :'blacklight.search.fields.subject',
                           limit: 5
    config.add_facet_field 'keyword_sim',
                           label: :'blacklight.search.fields.keyword',
                           limit: 5
    config.add_facet_field 'language_label_ssim',
                           label: :'blacklight.search.fields.language',
                           limit: 5
    config.add_facet_field 'location_label_ssim',
                           label: :'blacklight.search.fields.location',
                           limit: 5
    config.add_facet_field 'years_encompassed_iim',
                           include_in_advanced_search: false,
                           label: :'blacklight.search.fields.years_encompassed',
                           range: true
    config.add_facet_field 'rights_statement_shortcode_ssim',
                           label: :'blacklight.search.fields.rights_statement',
                           limit: 5

    #
    # admin facets
    #
    config.add_facet_field 'visibility_ssi',
                           label: :'blacklight.search.fields.visibility',
                           limit: 5,
                           admin: true,
                           helper_method: :render_catalog_visibility_facet
    config.add_facet_field 'depositor_ssim',
                           label: :'blacklight.search.fields.depositor',
                           limit: 5,
                           admin: true
    config.add_facet_field 'proxy_depositor_ssim',
                           label: :'blacklight.search.fields.proxy_depositor',
                           limit: 5,
                           admin: true
    config.add_facet_field 'admin_set_sim',
                           label: :'blacklight.search.fields.admin_set',
                           limit: 5,
                           admin: true

    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field 'generic_type_sim', if: false

    # see also: has_model_ssim for the 'View collections' link
    config.add_facet_field 'has_model_ssim',
                           label: :'blacklight.search.fields.has_model',
                           if: false

    # Facets from the Work-level that aren't provided in the catalog
    config.add_facet_field 'subject_ocm_ssim',
                           label: :'blacklight.search.facets.subject_ocm',
                           if: false
    config.add_facet_field 'research_assistance_ssim',
                           label: :'blacklight.search.facets.research_assistance',
                           if: false

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
                           label: :'blacklight.search.fields.resource_type',
                           link_to_search: 'resource_type_ssim'
    config.add_index_field 'academic_department_tesim',
                           itemprop: 'department',
                           label: :'blacklight.search.fields.academic_department',
                           link_to_search: 'academic_department_sim'
    config.add_index_field 'keyword_tesim',
                           itemprop: 'keywords',
                           label: :'blacklight.search.fields.keyword',
                           link_to_search: 'keyword_sim'
    config.add_index_field 'subject_tesim',
                           itemprop: 'about',
                           label: :'blacklight.search.fields.subject',
                           link_to_search: 'subject_sim'
    config.add_index_field 'creator_tesim',
                           itemprop: 'creator',
                           label: :'blacklight.search.fields.creator',
                           link_to_search: 'creator_sim'
    config.add_index_field 'contributor_tesim',
                           itemprop: 'contributor',
                           label: :'blacklight.search.fields.contributor',
                           link_to_search: 'contributor_sim'
    config.add_index_field 'publisher_tesim',
                           itemprop: 'publisher',
                           label: :'blacklight.search.fields.publisher',
                           link_to_search: 'publisher_sim'
    config.add_index_field 'language_label_ssim',
                           itemprop: 'inLanguage',
                           label: :'blacklight.search.fields.language',
                           link_to_search: 'language_sim'
    config.add_index_field 'date_issued_ssim',
                           label: :'blacklight.search.fields.date_issued'
    config.add_index_field 'rights_statement_tesim',
                           helper_method: :rights_statement_links,
                           label: :'blacklight.search.fields.rights_statement'
    config.add_index_field 'license_tesim',
                           helper_method: :license_links,
                           label: :'blacklight.search.fields.license'
    config.add_index_field 'embargo_release_date_dtsi',
                           label: :'blacklight.search.fields.embargo_release_date',
                           helper_method: :human_readable_date
    config.add_index_field 'lease_expiration_date_dtsi',
                           label: :'blacklight.search.fields.lease_expiration_date',
                           helper_method: :human_readable_date

    #
    # search field configuration
    #
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      fields = %w[
        title_tesim subtitle_tesim title_alternative_tesim
        creator_tesim contributor_tesim publisher_tesim editor_tesim
        source_tesim abstract_tesim description_tesim note_tesim
        subject_label_tesim identifier_ssim bibliographic_citation_tesim
        english_language_date_teim file_format_tesim
        extracted_text_tsimv
      ]

      field.solr_parameters = {
        qf: fields.join(' '),
        pf: 'extracted_text_tsimv'
      }
    end

    config.add_search_field('title', label: 'Title') do |field|
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

    config.add_search_field('author', label: 'Author') do |field|
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

    config.add_search_field('full_text', label: 'Full Text') do |field|
      field.solr_parameters = {
        qf: 'extracted_text_tsimv',
        pf: 'extracted_text_tsimv'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    #
    # @note: not optimal, but we're using the label text here, rather than locales
    # because the sort dropdown that appears on collection#show views doesn't run
    # the labels through +I18n.t+ first, displaying only the symbolized translation
    # keys we're sending here.
    config.add_sort_field 'score desc, system_create_dtsi desc', label: "Relevance"
    config.add_sort_field 'date_sort_dtsi asc', label: "Date \u25B2"
    config.add_sort_field 'date_sort_dtsi desc', label: "Date \u25BC"
    config.add_sort_field 'title_sort_si asc', label: "Title \u25B2"
    config.add_sort_field 'title_sort_si desc', label: "Title \u25BC"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # OAI-PMH provider params
    # (see: https://github.com/projectblacklight/blacklight_oai_provider#configuration)
    config.oai = {
      provider: {
        repository_name: 'Lafayette Digital Repository',
        repository_url: 'https://ldr.lafayette.edu',
        record_prefix: 'oai:ldr',
        admin_email: 'dss@lafayette.edu'
      },

      document: {
        set_model: Spot::OaiCollectionSolrSet,
        set_fields: [
          { label: 'collection', solr_field: 'member_of_collections_ssim' }
        ]
      }
    }
  end
end
