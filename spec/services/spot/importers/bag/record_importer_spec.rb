# frozen_string_literal: true
RSpec.describe Spot::Importers::Bag::RecordImporter do
  it_behaves_like 'a RecordImporter',
                  empty_file_warning: '[WARN] no files found for this bag\n'
end
