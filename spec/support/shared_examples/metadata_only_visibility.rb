# frozen_string_literal: true
RSpec.shared_examples 'it accepts "metadata" as a visibility' do
  let(:work) { described_class.new }
  let(:public_group) { Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC }
  let(:admin_group) { Ability.admin_group_name }

  describe '#visibility' do
    subject { work.visibility }

    context 'when discover_groups are public and read_groups are admin' do
      before do
        work.discover_groups = [public_group]
        work.read_groups = [admin_group]
      end

      it { is_expected.to eq 'metadata' }
    end
  end

  describe '#visibility=' do
    context 'when "metadata"' do
      it 'sets discover_groups to public access' do
        expect { work.visibility = 'metadata' }
          .to change { work.discover_groups }
          .from([])
          .to([public_group])
      end

      it 'sets read_groups to admin access' do
        expect { work.visibility = 'metadata' }
          .to change { work.read_groups }
          .from([])
          .to([admin_group])
      end
    end

    context 'when changing to private' do
      before { work.visibility = 'metadata' }

      it 'clears out discover_groups' do
        expect(work.discover_groups).not_to be_empty

        expect { work.visibility = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
          .to change { work.discover_groups }
          .from([::Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC])
          .to([])
      end
    end

    context 'when authenticated' do
      it 'sets discover_groups to public access' do
        expect { work.visibility = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
          .to change { work.discover_groups }
          .from([])
          .to([::Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC])
      end
    end

    context 'when invalid visibility' do
      it 'raises an ArgumentError' do
        expect { work.visibility = 'nonsense' }.to raise_error(ArgumentError)
      end
    end
  end
end
