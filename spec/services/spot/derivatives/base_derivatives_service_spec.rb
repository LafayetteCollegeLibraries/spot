# frozen_string_literal: true
RSpec.describe Spot::Derivatives::BaseDerivativeService, derivatives: true do
  let(:valid_file_set) do
    FactoryBot.valkyrie_create(:hyrax_file_metadata, :image)
  end

  it_behaves_like "a Hyrax::DerivativeService"
end
