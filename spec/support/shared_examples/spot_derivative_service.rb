# frozen_string_literal: true
RSpec.shared_examples 'a Spot::DerivativeService' do
  before do
    raise 'valid_file_metadata must be set with `let(:valid_file_metadata)`' unless
      defined? valid_file_metadata
  end

  subject { described_class.new(file_metadata) }
  let(:file_metadata) { valid_file_metadata }

  it { is_expected.to respond_to(:create_derivatives).with(1).arguments }

  it { is_expected.to respond_to(:cleanup_derivatives).with(0).arguments }

  it { is_expected.to respond_to(:file_metadata) }

  it { is_expected.to respond_to(:file_set) }

  it { is_expected.to respond_to(:mime_type) }

  describe "#valid?" do
    context "when given a file_set it handles" do
      let(:file_metadata) { valid_file_metadata }
      it { is_expected.to be_valid }
    end
  end

  it "takes a fileset as an argument" do
    obj = described_class.new(valid_file_metadata)
    expect(obj.file_metadata).to eq valid_file_metadata
  end
end
