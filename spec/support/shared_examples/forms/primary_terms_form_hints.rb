# frozen_string_literal: true
RSpec.shared_examples 'it has hints for all primary_terms' do
  describe '.primary_terms form hints' do
    work_klass = described_class.name.to_s.split('::').last.gsub(/Form$/, '').constantize

    described_class.new(work_klass.new, nil, nil).primary_terms.each do |term|
      describe "for #{term}" do
        subject do
          I18n.t("simple_form.hints.defaults.#{term}", locale: :en, default: nil)
        end

        it { is_expected.not_to be_nil, "Hint missing for #{work_klass}##{term}" }
      end
    end
  end
end
