# frozen_string_literal: true
RSpec.describe IdentifierFormFields do
  before do
    class Hyrax::ThingForm < Hyrax::Forms::WorkForm
      class_attribute :identifier_is_multiple
      self.identifier_is_multiple = false

      include IdentifierFormFields

      def self.multiple?(field)
        field.to_s == 'identifier' ? identifier_is_multiple : false
      end

      def multiple?(field)
        self.class.multiple?(field)
      end
    end

    Hyrax::ThingForm.identifier_is_multiple = multiple
  end

  after do
    Hyrax.send(:remove_const, :ThingForm)
  end

  describe '.build_permitted_params' do
    subject { Hyrax::ThingForm.build_permitted_params }

    context 'when :identifier is singular' do
      let(:multiple) { false }

      it { is_expected.to include :identifier_prefix }
      it { is_expected.to include :identifier_value }
    end

    context 'when :identifier is multiple' do
      let(:multiple) { true }
      let(:expected_obj) do
        {
          identifier_prefix: [],
          identifier_value: []
        }
      end

      it { is_expected.to include expected_obj }
    end
  end
end
