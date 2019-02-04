# frozen_string_literal: true
RSpec.describe RightsStatementHelper do
  describe '#rights_statement_icon_path_for' do
    subject(:node) { Capybara::Node::Simple.new(icon) }

    let(:rights_service) { Hyrax.config.rights_statement_service_class.new }
    let(:icon) { helper.rights_statement_icon(uri, label) }

    shared_examples 'an icon link for the rights_statement' do
      let(:image) { helper.image_path("rights-icons/#{key}.svg") }

      it { is_expected.to have_css 'a img' }
      it { is_expected.to have_link(nil, href: uri) }

      it "uses the label as the image's alt-text" do
        expect(node.find('img')['alt']).to eq label
      end

      it 'opens the link in a new window' do
        expect(node.find('a')['target']).to eq '_blank'
      end
    end

    {
      'http://creativecommons.org/publicdomain/mark/1.0/' => 'pd-mark',
      'http://rightsstatements.org/vocab/NoC-NC/1.0/' => 'rs-noc-nc',
      'http://rightsstatements.org/vocab/NoC-OKLR/1.0/' => 'rs-noc-oklr',
      'http://creativecommons.org/publicdomain/zero/1.0/' => 'pd-zero',
      'http://creativecommons.org/licenses/by/4.0/' => 'cc-by',
      'http://creativecommons.org/licenses/by-sa/4.0/' => 'cc-by-sa',
      'http://creativecommons.org/licenses/by-nd/4.0/' => 'cc-by-nd',
      'http://creativecommons.org/licenses/by-nc/4.0/' => 'cc-by-nc',
      'http://creativecommons.org/licenses/by-nc-sa/4.0/' => 'cc-by-nc-sa',
      'http://creativecommons.org/licenses/by-nc-nd/4.0/' => 'cc-by-nc-nd',
      'http://rightsstatements.org/vocab/InC/1.0/' => 'rs-inc',
      'http://rightsstatements.org/vocab/InC-EDU/1.0/' => 'rs-inc-edu',
      'http://rightsstatements.org/vocab/InC-OW-EU/1.0/' => 'rs-inc-ow-eu',
      'http://rightsstatements.org/vocab/CNE/1.0/' => 'rs-cne',
      'http://rightsstatements.org/vocab/InC-NC/1.0/' => 'rs-inc-nc',
      'http://rightsstatements.org/vocab/InC-RUU/1.0/' => 'rs-inc-ruu',
      'http://rightsstatements.org/vocab/NoC-CR/1.0/' => 'rs-noc-cr',
      'http://rightsstatements.org/vocab/NoC-US/1.0/' => 'rs-noc-us',
      'http://rightsstatements.org/vocab/UND/1.0/' => 'rs-und',
      'http://rightsstatements.org/vocab/NKC/1.0/' => 'rs-nkc'
    }.each_pair do |license, svg_key|
      context license do
        let(:uri) { license }
        let(:label) { rights_service.label(uri) }
        let(:key) { svg_key }

        it_behaves_like 'an icon link for the rights_statement'
      end
    end

    context 'when a URI is not expected' do
      let(:uri) { 'http://lafayette.edu' }
      let(:label) { nil }

      it { is_expected.not_to have_css 'a img' }
      it { is_expected.to have_css 'a span.fa.fa-external-link' }
      it { is_expected.to have_link(uri, href: uri) }
    end
  end
end
