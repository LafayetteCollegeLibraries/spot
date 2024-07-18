module IndexesRightsStatementsAndLabels
  def to_solr
    super.tap do |document|
      resource.rights_statement.each do |original_uri|
        value = original_uri.is_a?(ActiveTriples::Resource) ? original_uri.id : original_uri

        document['rights_statement_ssim'] ||= []
        document['rights_statement_ssim'] << value

        document['rights_statement_label_ssim'] ||= []
        document['rights_statement_label_ssim'] << rights_service.label(value) { value }

        document['rights_statement_shortcode_ssim'] ||= []
        document['rights_statement_shortcode_ssim'] << rights_service.shortcode(value) { nil }
      end
    end
  end

  def rights_service
    @rights_service ||= Hyrax.config.rights_statement_service_class.new
  end
end