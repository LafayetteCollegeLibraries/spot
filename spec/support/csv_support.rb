require 'csv'

module CsvSupport
  def self.parse_bag_metadata_to_hash(path_to_file)
    {}.tap do |output|
      ::CSV.foreach(path_to_file) do |(key, value)|
        output[key] = value.split(';')
      end
    end
  end
end
