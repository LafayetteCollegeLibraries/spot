# frozen_string_literal: true

class PublicationIndexer < Hyrax::WorkIndexer
  include IndexesRightsStatements

  def rdf_service
    Spot::DeepIndexingService
  end

  def generate_solr_document
    super.tap do |solr_doc|
      store_license(solr_doc)
      store_language_label(solr_doc)
    end
  end

  private

  # we're storing licenses but not indexing them
  def store_license(doc)
    doc['license_tsm'] = object.license
  end

  def store_language_label(doc)
    label_key = 'language_label_ssim'
    doc[label_key] ||= []

    object.language.map do |lang|
      doc[label_key] << Spot::ISO6391.label_for(lang) || lang
    end
  end
end
