# frozen_string_literal: true
RSpec.describe Spot::Importers::Base::RecordImporter, feature: [:csv_ingest_service] do
  it_behaves_like 'a RecordImporter'
end
