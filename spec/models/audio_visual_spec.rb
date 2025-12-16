# frozen_string_literal: true
RSpec.describe AudioVisual do
  subject { described_class.new }

  it_behaves_like 'it includes Spot::WorkBehavior'

  it { is_expected.to respond_to :date, :date= }
  it { is_expected.to respond_to :date_associated, :date_associated= }
  it { is_expected.to respond_to :inscription, :inscription= }
  it { is_expected.to respond_to :original_item_extent, :original_item_extent= }
  it { is_expected.to respond_to :repository_location, :repository_location= }
  it { is_expected.to respond_to :research_assistance, :research_assistance= }
  it { is_expected.to respond_to :barcode, :barcode= }
  it { is_expected.to respond_to :provenance, :provenance= }
end
