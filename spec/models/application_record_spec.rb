# frozen_string_literal: true
RSpec.describe ApplicationRecord do
  it 'is an abstract class' do
    expect(described_class.abstract_class).to be true
  end
end
