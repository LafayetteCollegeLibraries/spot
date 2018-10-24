class PublicationIndexer < Hyrax::WorkIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      translate_iso_language(solr_doc)
      store_license(solr_doc)
    end
  end

  private

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
