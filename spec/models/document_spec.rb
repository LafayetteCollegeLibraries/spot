# Generated via
#  `rails generate hyrax:work Document`
RSpec.describe Document do
  describe '.create' do
    context 'without a title provided' do
      it 'raises a validation error' do
        expect { Document.create! }.to raise_error(ActiveFedora::RecordInvalid)
      end
    end
  end

  describe '#abstract' do
    let(:abstract_text) do
      'A summary of a text, scientific article, document, speech, etc.'
    end

    context 'with a new Document' do
      subject { described_class.new }

      its(:abstract) { is_expected.to be_nil }
    end

    context 'with a Document that has an abstract' do
      subject do
        described_class.new.tap do |doc|
          doc.abstract = abstract_text
        end
      end

      its(:abstract) { is_expected.to eq abstract_text }
    end
  end

  describe '#issued' do
    let(:issued_date) { '2018-03-14' }

    context 'with a new Document' do
      subject { described_class.new }

      its(:issued) { is_expected.to be_nil }
    end

    context 'with a Document that has an issued date' do
      subject do
        described_class.new.tap do |doc|
          doc.issued = issued_date
        end
      end

      its(:issued) { is_expected.to eq issued_date }
    end
  end

  describe '#provenance' do
    let(:where_they_from) { 'Bethlehem, PA' }

    context 'with a new Document' do
      subject { described_class.new }

      its(:provenance) { is_expected.to be_nil }
    end

    context 'with a Document that has provenance' do
      subject do
        described_class.new.tap do |doc|
          doc.provenance = where_they_from
        end
      end

      its(:provenance) { is_expected.to eq where_they_from }
    end
  end

  describe '#department' do
    let(:departments) { %w[Art Science History] }

    context 'with a new Document' do
      subject { described_class.new }

      its(:department) { is_expected.to be_empty }
    end

    context 'with a Document that has departments' do
      subject do
        described_class.new.tap do |doc|
          doc.department = departments
        end
      end

      its(:department) { is_expected.to eq departments }
    end
  end

  describe '#division' do
    let(:bio_division) { %w[Biology] }

    context 'with a new Document' do
      subject { described_class.new }

      its(:division) { is_expected.to be_empty }
    end

    context 'with a Document that has divisions' do
      subject do
        described_class.new.tap do |doc|
          doc.division = bio_division
        end
      end

      its(:division) { is_expected.to eq bio_division }
    end
  end

  describe '#organization' do
    let(:org) { ['Lafayette College'] }

    context 'with a new Document' do
      subject { described_class.new }

      its(:organization) { is_expected.to be_empty }
    end

    context 'with a Document that has organizations' do
      subject do
        described_class.new.tap do |doc|
          doc.organization = org
        end
      end

      its(:organization) { is_expected.to eq org }
    end
  end
end
