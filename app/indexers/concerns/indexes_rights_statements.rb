# frozen_string_literal: true
#
# Mixin to index URIs, labels, and shortcodes for Rights Statements
#
# @example
#   class ThingIndexer < Hyrax::WorkIndexer
#     include IndexesRightsStatements
#   end
#
module IndexesRightsStatements
  # @return [Hash]
  def generate_solr_document
    super.tap { |solr_doc| add_rights_statement_label(solr_doc) }
  end

  private

  # @return [String]
  def value_key
    'rights_statement_ssim'
  end

  # @return [String]
  def label_key
    'rights_statement_label_ssim'
  end

  def shortcode_key
    'rights_statement_shortcode_ssim'
  end

  # @param [Hash]
  # @return [void]
  def add_rights_statement_label(doc)
    doc[value_key] ||= []
    doc[label_key] ||= []
    doc[shortcode_key] ||= []

    object.rights_statement.each do |original_value|
      value = original_value.is_a?(ActiveTriples::Resource) ? original_value.id : original_value

      doc[value_key] << value
      doc[label_key] << get_label_value(value)
      doc[shortcode_key] << get_shortcode(value)
    end
  end

  # @param [String] value the URI of the rights statement
  # @return [String] the label of the URI (returns the URI if not found)
  def get_label_value(value)
    rights_service.label(value) { value }
  end

  # @param [String] value the URI of the rights statement
  # @return [String, nil] the shortcode of the URI
  def get_shortcode(uri)
    rights_service.shortcode(uri) { nil }
  end

  # @return [Hyrax::RightsStatementService]
  def rights_service
    @rights_service ||= Hyrax.config.rights_statement_service_class.new
  end
end
