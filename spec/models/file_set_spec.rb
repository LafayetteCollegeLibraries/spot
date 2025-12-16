# frozen_string_literal: true
RSpec.describe FileSet do
  subject { described_class.new }

  it_behaves_like 'it accepts "metadata" as a visibility'

  it { is_expected.to respond_to :title, :title= }
end
