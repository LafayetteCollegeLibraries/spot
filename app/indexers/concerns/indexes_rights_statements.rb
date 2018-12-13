# frozen_string_literal: true
#
# Lets us index the rights-statement labels along-side the URIs
module IndexesRightsStatements
  # @return [Hash]
  def generate_solr_document
    super.tap do |solr_document|
      add_rights_statement_label(solr_document)
    end
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

    # @param [Hash]
    # @return [void]
    def add_rights_statement_label(doc)
      doc[value_key] ||= []
      doc[label_key] ||= []

      object.rights_statement.each do |original_value|
        doc[value_key] << original_value
        doc[label_key] << get_label_value(original_value)
      end
    end

    # @param [String] value the URI of the rights statement
    # @return [String] the label of the URI (returns the URI if not found)
    def get_label_value(value)
      rights_service.label(value)
    rescue KeyError
      value
    end

    # @return [Hyrax::RightsStatementService]
    def rights_service
      @rights_service ||= Hyrax.config.rights_statement_service_class.new
    end
end
