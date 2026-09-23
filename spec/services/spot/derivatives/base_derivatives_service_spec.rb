# frozen_string_literal: true
RSpec.describe Spot::Derivatives::BaseDerivativeService, derivatives: true do
  let(:valid_file_metadata) do
    FactoryBot.valkyrie_create(:hyrax_file_metadata, :pdf_file)
  end

  it_behaves_like "a Spot::DerivativeService"
end
