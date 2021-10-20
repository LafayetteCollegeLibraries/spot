# frozen_string_literal: true
RSpec.shared_examples 'it validates local authorities' do |options|
  options ||= {}

  raise 'validates-local-authorities shared_example requires :field and :authority options' unless
    options.include?(:field) && options.include?(:authority)

  let(:field) { options[:field] }
  let(:work_factory) { described_class.name.underscore.to_sym }
  let(:work) { build(work_factory, attributes) }
  let(:authority) { Qa::Authorities::Local::FileBasedAuthority.new(options[:authority]) }
  let(:attributes) { { field => [value] } }

  describe "validates #{options[:field]} using #{options[:authority]} authority" do
    context 'when value exists in authority' do
      let(:value) { authority.all.first[:id] }

      it 'passes validation' do
        expect(work.valid?).to be true
      end
    end

    context 'when a value does not exist in the authority' do
      let(:value) { '__ NOT A VALID VALUE __' }

      it 'adds an error to the work' do
        expect(work.valid?).to be false
        expect(work.errors[field]).to include %("#{value}" is not a valid #{field.to_s.titleize}.)
      end
    end
  end
end
