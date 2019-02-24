# frozen_string_literal: true
module IndexesLanguageAndLabel
  # adds:
  #   - language_ssim (the original 2-character value)
  #   - language_label_ssim (the translated label or original value)
  #
  # @return [Hash]
  def generate_solr_doc
    super.tap do |solr_doc|
      break solr_doc if object.language.empty?

      solr_doc['language_ssim'] = object.language
      solr_doc['language_label_ssim'] ||= []

      object.language.each do |lang|
        label = Spot::ISO6391.label_for(lang) || lang

        solr_doc['language_label_ssim'] << label
      end
    end
  end
end
