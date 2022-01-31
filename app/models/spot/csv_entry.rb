# frozen_string_literal: true
module Spot
  class CsvEntry < ::Bulkrax::CsvEntry
    JOIN_CHARACTER = '|'

    def build_export_metadata
      super

      parsed_metadata['depositor'] = parse_user_string(hyrax_record.depositor)

      build_controlled_properties
      build_language_labels
      build_advisors
      build_rights_statement_labels
    end

    # Join our filenames with a pipe ('|') rather than ennumerating each with its own heading
    # (eg "file_1", "file_2")
    #
    # @return [void]
    def build_files
      parsed_metadata['file'] = hyrax_record.file_sets.map { |fs| filename(fs).to_s if filename(fs).present? }.compact.join(JOIN_CHARACTER)
    end

    # Join a field's value with a pipe ('|') rather than ennumerating each with its own heading
    # (eg "subject_1", "subject_2")
    #
    # @param [#to_s] key
    #   The field's key
    # @param [HashWithIndifferentAccess] _config
    #   The field's mapping configuration (see config/initializers/bulkrax.rb)
    # @return [void]
    def build_value(key, _config)
      data = hyrax_record.send(key.to_s)
      wrapped_data = data.is_a?(ActiveTriples::Relation) ? data : Array.wrap(data)
      parsed_metadata[key_for_export(key)] = wrapped_data.map { |d| prepare_export_data(d) }.join(JOIN_CHARACTER)
    end

    private

    def build_advisors
      parsed_metadata['advisor'] = hyrax_record.advisor.map { |advisor_email| parse_user_string(advisor_email) } if hyrax_record.respond_to?(:advisor)
    end

    def build_controlled_properties
      props = hyrax_record.class&.controlled_properties || []

      props.each do |field|
        parsed_metadata["#{field}_label"] = map_uri_labels(hyrax_record.send(field)) if hyrax_record.respond_to?(field)
      end
    end

    def build_language_labels
      parsed_metadata['language_label'] = hyrax_record.language.map do |shortcode|
        Spot::ISO6391.label_for(shortcode)
      end.join(JOIN_CHARACTER)
    end

    def build_rights_statement_labels
      parsed_metadata['rights_statement_label'] = hyrax_record.rights_statement.map do |rs|
        uri = rs.rdf_subject.to_s
        rights_statement_service.label(uri) { uri }
      end.join(JOIN_CHARACTER)
    end

    def map_uri_labels(values)
      values.map(&:rdf_label).flatten.join(JOIN_CHARACTER)
    end

    def parse_user_string(value)
      user = ::User.find_by(email: value)
      return value if user.nil? || user.display_name.blank?

      %("#{user.display_name}" <#{user.email}>)
    end

    def rights_statement_service
      @rights_statement_service ||= Hyrax.config.rights_statement_service_class.new
    end
  end
end
