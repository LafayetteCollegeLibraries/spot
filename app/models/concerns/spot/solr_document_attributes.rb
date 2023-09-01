# frozen_string_literal: true
module Spot
  # Various model attributes for the single SolrDocument model. Since that model wraps
  # every kind of Solr document, we need to ensure that _all_ of the models attributes
  # are available.
  #
  #
  #
  # @todo Remove {.attribute} definition when Hyrax upgrades to Blacklight >=7
  module SolrDocumentAttributes
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    included do
      # Hyrax properties
      attribute :admin_set,              ::Blacklight::Types::String, 'admin_set_tesim'
      attribute :date_uploaded,          ::Blacklight::Types::Date,   'date_uploaded_dtsi'
      attribute :depositor,              ::Blacklight::Types::String, 'depositor_ssim'
      attribute :discover_groups,        ::Blacklight::Types::Array,  ::Ability.discover_group_field

      # Spot::CoreMetadata mixin properties
      attribute :contributor,            ::Blacklight::Types::Array,  'contributor_tesim'
      attribute :creator,                ::Blacklight::Types::Array,  'creator_tesim'
      attribute :description,            ::Blacklight::Types::Array,  'description_tesim'
      attribute :identifier,             ::Blacklight::Types::Array,  'identifier_ssim'
      attribute :keyword,                ::Blacklight::Types::Array,  'keyword_tesim'
      attribute :language,               ::Blacklight::Types::Array,  'language_ssim'
      attribute :language_label,         ::Blacklight::Types::Array,  'language_label_ssim'
      attribute :location,               ::Blacklight::Types::Array,  'location_ssim'
      attribute :location_label,         ::Blacklight::Types::Array,  'location_label_tesim'
      attribute :note,                   ::Blacklight::Types::Array,  'note_tesim'
      attribute :physical_medium,        ::Blacklight::Types::Array,  'physical_medium_tesim'
      attribute :publisher,              ::Blacklight::Types::Array,  'publisher_tesim'
      attribute :related_resource,       ::Blacklight::Types::Array,  'related_resource_tesim'
      attribute :resource_type,          ::Blacklight::Types::Array,  'resource_type_tesim'
      attribute :rights_holder,          ::Blacklight::Types::Array,  'rights_holder_tesim'
      attribute :rights_statement,       ::Blacklight::Types::Array,  'rights_statement_ssim'
      attribute :rights_statement_label, ::Blacklight::Types::Array,  'rights_statement_label_ssim'
      attribute :source,                 ::Blacklight::Types::Array,  'source_tesim'
      attribute :subject,                ::Blacklight::Types::Array,  'subject_ssim'
      attribute :subject_label,          ::Blacklight::Types::Array,  'subject_label_tesim'
      attribute :subtitle,               ::Blacklight::Types::Array,  'subtitle_tesim'
      attribute :title,                  ::Blacklight::Types::Array,  'title_tesim'
      attribute :title_alternative,      ::Blacklight::Types::Array,  'title_alternative_tesim'
      attribute :source_identifier,      ::Blacklight::Types::String, 'source_identifier_ssim'

      # Spot::InstitutionalMetadata mixin properties
      attribute :academic_department,    ::Blacklight::Types::Array,  'academic_department_tesim'
      attribute :division,               ::Blacklight::Types::Array,  'division_tesim'
      attribute :organization,           ::Blacklight::Types::Array,  'organization_tesim'

      # Publication properties
      attribute :abstract,               ::Blacklight::Types::Array,  'abstract_tesim'
      attribute :bibliographic_citation, ::Blacklight::Types::Array,  'bibliographic_citation_tesim'
      attribute :date_available,         ::Blacklight::Types::Array,  'date_available_ssim'
      attribute :date_issued,            ::Blacklight::Types::Array,  'date_issued_ssim'
      attribute :editor,                 ::Blacklight::Types::Array,  'editor_tesim'
      attribute :license,                ::Blacklight::Types::Array,  'license_ssim'

      # Image properties
      attribute :date,                   ::Blacklight::Types::Array,  'date_ssim'
      attribute :date_associated,        ::Blacklight::Types::Array,  'date_associated_ssim'
      attribute :date_scope_note,        ::Blacklight::Types::Array,  'date_scope_note_tesim'
      attribute :donor,                  ::Blacklight::Types::Array,  'donor_ssim'
      attribute :inscription,            ::Blacklight::Types::Array,  'inscription_tesim'
      attribute :original_item_extent,   ::Blacklight::Types::Array,  'original_item_extent_tesim'
      attribute :repository_location,    ::Blacklight::Types::Array,  'repository_location_ssim'
      attribute :requested_by,           ::Blacklight::Types::Array,  'requested_by_ssim'
      attribute :research_assistance,    ::Blacklight::Types::Array,  'research_assistance_ssim'
      attribute :subject_ocm,            ::Blacklight::Types::Array,  'subject_ocm_ssim'

      # StudentWork properties
      attribute :access_note,            ::Blacklight::Types::Array,  'access_note_tesim'
      attribute :advisor,                ::Blacklight::Types::Array,  'advisor_ssim'
      attribute :advisor_label,          ::Blacklight::Types::Array,  'advisor_label_ssim'

      # FileSet properties
      attribute :file_set_ids,           ::Blacklight::Types::Array,  'file_set_ids_ssim'
      attribute :file_size,              ::Blacklight::Types::String, 'file_size_lts'
      attribute :original_checksum,      ::Blacklight::Types::String, 'original_checksum_tesim'
      attribute :page_count,             ::Blacklight::Types::String, 'page_count_tesim'

      # Collection properties
      attribute :collection_slug,        ::Blacklight::Types::String, 'collection_slug_ssi'
      attribute :sponsor,                ::Blacklight::Types::Array,  'sponsor_tesim'

      # Solr fields added by indexers
      attribute :local_identifier,       ::Blacklight::Types::Array,  'identifier_local_ssim'
      attribute :permalink,              ::Blacklight::Types::String, 'permalink_ss'
      attribute :standard_identifier,    ::Blacklight::Types::Array,  'identifier_standard_ssim'

      # dates
      attribute :date_modified,          ::Blacklight::Types::Date,   'date_modified_dtsi'

      # Solr fields for Google Scholar citation
      attribute :citation_journal_title, ::Blacklight::Types::String, 'citation_journal_title_ss'
      attribute :citation_volume,        ::Blacklight::Types::String, 'citation_volume_ss'
      attribute :citation_issue,         ::Blacklight::Types::String, 'citation_issue_ss'
      attribute :citation_firstpage,     ::Blacklight::Types::String, 'citation_firstpage_ss'
      attribute :citation_lastpage,      ::Blacklight::Types::String, 'citation_lastpage_ss'

      # Bulkrax properties
      attribute :source_identifier, ::Blacklight::Types::String, 'source_identifier_ssim'
    end

    module ClassMethods
      def attribute(name, type, field)
        define_method name do
          type.coerce(self[field])
        end
      end
    end
  end
end
