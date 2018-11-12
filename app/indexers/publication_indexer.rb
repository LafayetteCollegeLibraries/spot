class PublicationIndexer < Hyrax::WorkIndexer
  include IndexesRightsStatements

  def rdf_service
    Spot::DeepIndexingService
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
