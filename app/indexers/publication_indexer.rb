class PublicationIndexer < Hyrax::WorkIndexer
  # replaces the work that including the `Hyrax::IndexesLinkedMetadata`
  # mixin would do, without also bringing along metadata baggage from
  # `Hyrax::BasicMetadataIndexer`.
  def rdf_service
    Hyrax::DeepIndexingService
  end

  def generate_solr_document
    super.tap do |solr_doc|
      store_license(solr_doc)
    end
  end

  private

  # we're storing licenses but not indexing them
  def store_license(doc)
    doc['license_tsm'] = object.license
  end
end
