# frozen_string_literal: true
RSpec.describe StudentWork do
  subject { described_class.new }

  it_behaves_like 'it includes Spot::WorkBehavior'

  it { is_expected.to respond_to :abstract, :abstract= }
  it { is_expected.to respond_to :access_note, :access_note= }
  it { is_expected.to respond_to :advisor, :advisor= }
  it { is_expected.to respond_to :date, :date= }
  it { is_expected.to respond_to :date_available, :date_available= }
end
