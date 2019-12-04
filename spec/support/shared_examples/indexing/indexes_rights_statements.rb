# frozen_string_literal: true
RSpec.shared_examples 'it indexes rights statements' do
  subject { solr_document[key] }

  let(:work_klass) { described_class.name.gsub(/Indexer$/, '').downcase.to_sym }
  let(:work) { build(work_klass, rights_statement: rights_statement) }
  let(:indexer) { described_class.new(work) }
  let(:solr_document) { indexer.generate_solr_document }
  let(:rights_statement) { ['http://creativecommons.org/publicdomain/zero/1.0/'] }

  describe 'rights statement URIs' do
    let(:key) { 'rights_statement_ssim' }

    it { is_expected.to eq ['http://creativecommons.org/publicdomain/zero/1.0/'] }
  end

  describe 'rights statement labels' do
    let(:key) { 'rights_statement_label_ssim' }

    it { is_expected.to eq ['Creative Commons CC0 1.0 Universal Public Domain Dedication'] }
  end

  describe 'rights statement shortcodes' do
    let(:key) { 'rights_statement_shortcode_ssim' }

    it { is_expected.to eq ['CC0'] }
  end
end
