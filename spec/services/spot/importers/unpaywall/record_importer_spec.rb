# frozen_string_literal: true
RSpec.describe Spot::Importers::Unpaywall::RecordImporter do
  it_behaves_like 'a RecordImporter',
                  empty_file_warning: /^\[WARN\] no open\-access files available for/
end
