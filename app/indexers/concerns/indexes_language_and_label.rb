# frozen_string_literal: true
module IndexesLanguageAndLabel
  # adds:
  #   - language_ssim (the original 2-character value)
  #   - language_label_ssim (the translated label or original value)
  #
  # @return [Hash]
  def generate_solr_document
    super.tap do |doc|
      break doc if object.language.empty?

      doc[value_field] ||= []
      doc[label_field] ||= []

      object.language.each do |lang|
        doc[value_field] << lang
        doc[label_field] << Spot::ISO6391.label_for(lang)
      end
    end
  end

private

  # @return [String]
  def label_field
    'language_label_ssim'
  end

  # @return [String]
  def value_field
    'language_ssim'
  end
end
