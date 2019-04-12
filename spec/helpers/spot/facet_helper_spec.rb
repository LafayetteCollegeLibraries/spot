# frozen_string_literal: true
RSpec.describe Spot::FacetHelper do
  include BlacklightHelper

  before do
    allow(helper).to receive(:blacklight_config).and_return blacklight_config
  end

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field 'creator_ssim'
      config.add_facet_field 'subject_ssim'
      config.add_facet_field 'depositor_ssim', admin: true
      config.add_facet_field 'admin_set_ssim', admin: true
    end
  end

  describe '.general_facet_names' do
    subject { helper.general_facet_names }

    it { is_expected.to eq ['creator_ssim', 'subject_ssim'] }
  end

  describe '.admin_facet_names' do
    subject { helper.admin_facet_names }

    it { is_expected.to eq ['depositor_ssim', 'admin_set_ssim'] }
  end
end
