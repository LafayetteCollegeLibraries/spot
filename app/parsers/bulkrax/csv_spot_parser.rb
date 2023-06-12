# frozen_string_literal: true

require 'csv'
module Bulkrax
  class CsvSpotParser < CsvParser # rubocop:disable Metrics/ClassLength
    def records(_opts = {})
      return @records if @records.present?
      
      client = Aws::S3::Client.new()
      file_for_import = only_updates ? parser_fields['partial_import_file_path'] : import_file_path
      file_directory = File.dirname(file_for_import)
      FileUtils.rm_r(['/spot/tmp/import/'])
      FileUtils.mkdir_p('/spot/tmp/import/'+file_directory+'/files')
      resp = client.get_object(response_target: '/spot/tmp/import/'+file_for_import, bucket: 'bulkrax-imports', key: file_for_import)
      # data for entry does not need source_identifier for csv, because csvs are read sequentially and mapped after raw data is read.
      csv_data = entry_class.read_data('/spot/tmp/import/'+file_for_import)
      resp2 = client.list_objects(bucket: "bulkrax-imports", prefix: file_directory)
      resp2.contents.each do |entry|
        puts '/spot/tmp/import/'+entry.key
        client.get_object(response_target: '/spot/tmp/import/'+entry.key, bucket: 'bulkrax-imports', key: entry.key)
      end
      importer.parser_fields['total'] = csv_data.count
      importer.save

      @records = csv_data.map { |record_data| entry_class.data_for_entry(record_data, nil, self) }
    end

    # Retrieve the path where we expect to find the files
    def path_to_files(**args)
      filename = args.fetch(:filename, '')

      return @path_to_files if @path_to_files.present? && filename.blank?
      @path_to_files = File.join(
          zip? ? importer_unzip_path : File.join('/spot/tmp/import/', File.dirname(import_file_path)), 'files', filename
        )
    end
  end
end