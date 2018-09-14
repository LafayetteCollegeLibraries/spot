# frozen_string_literal: true

class PublicationIndexer < Hyrax::WorkIndexer

  # replaces the work that including the `Hyrax::IndexesLinkedMetadata`
  # mixin would do, without also bringing along metadata baggage from
  # `Hyrax::BasicMetadataIndexer`.
  def rdf_service
    Hyrax::DeepIndexingService
  end

  def generate_solr_document
    super.tap do |solr_doc|
      attach_individual_identifiers(solr_doc)
      translate_iso_language(solr_doc)
      store_license(solr_doc)
    end
  end

  private

  def attach_individual_identifiers(doc)
    object.identifier.each do |id|
      prefix_match = id.match(/^(\w+):(.*)/)
      next if prefix_match.nil?

      prefix = prefix_match[1]
      value = prefix_match[2]

      # identifier_isbn_ssim => :symbol
      # identifier_isbn_sim => :facetable
      %W[identifier_#{prefix}_ssim identifier_#{prefix}_sim].each do |key|
        doc[key] ||= []
        doc[key] += Array(value)
      end
    end
  end

  # we're storing licenses but not indexing them
  def store_license(doc)
    doc['license_tsm'] = object.license
  end

  def translate_iso_language(doc)
    return if object.language.blank?
    doc['language_display_ssim'] = object.language.map do |lang|
      case lang
      when 'it' then 'Italian'
      when 'es' then 'Spanish'
      when 'fr' then 'French'
      when 'de' then 'German'
      when 'en' then 'English'
      when 'ja' then 'Japanese'
      else 'Other'
      end
    end
  end
end
