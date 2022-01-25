# frozen_string_literal: true
module Spot
  class CsvEntry < ::Bulkrax::CsvEntry
    def build_export_metadata
      super

      self.parsed_metadata['location_label'] = hyrax.record.location.map do |location|

      end
    end

    # Join our filenames with a pipe ('|') rather than ennumerating each with its own heading
    # (eg "file_1", "file_2")
    #
    # @return [void]
    def build_files
      self.parsed_metadata['file'] = hyrax_record.file_sets.map { |fs| filename(fs).to_s if filename(fs).present? }.compact.join('|')
    end

    # Join a field's value with a pipe ('|') rather than ennumerating each with its own heading
    # (eg "subject_1", "subject_2")
    #
    # @param [#to_s] key
    #   The field's key
    # @param [HashWithIndifferentAccess] config
    #   The field's mapping configuration (see config/initializers/bulkrax.rb)
    # @return [void]
    def build_value(key, config)
      data = hyrax_record.send(key.to_s)

      if data.is_a?(ActiveTriples::Relation)
        join_char = (config['join'] && config['join'].is_a?(String)) ? config['join'] : '|'
        self.parsed_metadata[key_for_export(key)] = data.map { |d| prepare_export_data(d) }.join(join_char).to_s
      else
        self.parsed_metadata[key_for_export(key)] = prepare_export_data(data)
      end
    end
  end
end
