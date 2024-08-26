# frozen_string_literal: true
RSpec.describe Spot::Derivatives::VideoDerivativeService, derivatives: true do
  let(:valid_file_set) { FileSet.new }

  it_behaves_like 'a Hyrax::DerivativeService'
end
