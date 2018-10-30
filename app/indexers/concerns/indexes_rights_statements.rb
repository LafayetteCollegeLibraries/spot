# frozen_string_literal: true

module IndexesRightsStatements
  def generate_solr_document
    super.tap do |solr_document|
      add_rights_statement_label(solr_document)
    end
  end

  private

  def value_key
    'rights_statement_ssim'
  end

  def label_key
    'rights_statement_label_ssim'
  end

  def add_rights_statement_label(doc)
    doc[value_key] ||= []
    doc[label_key] ||= []

    object.rights_statement.each do |original_value|
      doc[value_key] << original_value
      doc[label_key] << get_label_value(original_value)
    end
  end

  def get_label_value(value)
    rights_service.label(value)
  rescue KeyError
    value
  end

  def rights_service
    Hyrax.config.rights_statement_service_class.new
  end
end
