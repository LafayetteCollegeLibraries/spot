# frozen_string_literal: true
RSpec.describe Spot::FacetHelper, type: :helper do
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

  describe '.render_general_facet_partials' do
    before do
      allow(helper).to receive(:render_facet_partials)
      helper.render_general_facet_partials
    end

    it 'calls render_facet_partials with the general facet names' do
      expect(helper)
        .to have_received(:render_facet_partials)
        .with(helper.general_facet_names)
    end
  end

  describe '.admin_facet_names' do
    subject { helper.admin_facet_names }

    it { is_expected.to eq ['depositor_ssim', 'admin_set_ssim'] }
  end

  describe '.render_admin_facet_partials' do
    before do
      allow(helper).to receive(:render_facet_partials)
      helper.render_admin_facet_partials
    end

    it 'calls render_facet_partials with the admin facet names' do
      expect(helper)
        .to have_received(:render_facet_partials)
        .with(helper.admin_facet_names)
    end
  end

  describe '.render_catalog_visibility_facet' do
    subject { helper.render_catalog_visibility_facet(visibility) }

    let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    it { is_expected.to eq '<span class="label label-success">Public</span>' }
  end
end
