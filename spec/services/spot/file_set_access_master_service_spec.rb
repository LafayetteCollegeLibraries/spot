# frozen_string_literal: true
require 'hyrax/specs/shared_specs'

RSpec.describe Spot::FileSetAccessMasterService do
  before do
    allow(valid_file_set).to receive(:mime_type).and_return('image/jpeg')
  end

  let(:valid_file_set) { FileSet.new }

  it_behaves_like 'a Hyrax::DerivativeService'
end
