# frozen_string_literal: true
RSpec.describe Spot::Derivatives::AvValkyrieDerivativeService, derivatives: true do
  context "when given an audio file" do
    let(:valid_file_metadata) do
      FactoryBot.valkyrie_create(:hyrax_file_metadata, :audio_file, file_set_id: SecureRandom.uuid)
    end

    it_behaves_like "a Spot::DerivativeService"
  end

  context "when given an video file" do
    let(:valid_file_metadata) do
      FactoryBot.valkyrie_create(:hyrax_file_metadata, :video_file, file_set_id: SecureRandom.uuid)
    end

    it_behaves_like "a Spot::DerivativeService"
    end
end
