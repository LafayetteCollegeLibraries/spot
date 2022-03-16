# frozen_string_literal: true
RSpec.shared_examples 'it replaces line breaks with HTML' do |opts|
  opts ||= {}
  fields = opts.fetch(:for, [])

  raise 'No fields provided for example' if fields.empty?

  fields.each do |field|
    describe "for :#{field}" do
      subject { presenter.send(field.to_sym) }

      before do
        allow(presenter.solr_document).to receive(field.to_sym).and_return(original_value)
      end

      context 'new lines with carriage return' do
        let(:original_value) { ["Lorem ipsum dolor sit amet\r\n\r\nconsectetur adipiscing elit incididunt."] }

        it { is_expected.to eq ["Lorem ipsum dolor sit amet<br><br>consectetur adipiscing elit incididunt."] }
      end

      context 'new lines' do
        let(:original_value) { ["Lorem ipsum dolor sit amet\n\nconsectetur adipiscing elit incididunt."] }

        it { is_expected.to eq ["Lorem ipsum dolor sit amet<br><br>consectetur adipiscing elit incididunt."] }
      end
    end
  end
end
