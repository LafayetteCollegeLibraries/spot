# frozen_string_literal: true
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'ISO'
end

Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'spot/iso_6391' => 'Spot::ISO6391',
    'spot/rdf_authority_parser' => 'Spot::RDFAuthorityParser',
    'spot/work_csv_service' => 'Spot::WorkCSVService'
  )
end
