# frozen_string_literal: true
RSpec.describe Spot::Forms::WorkForm do
  subject(:form) { described_class.new(work, Ability.new(user), nil) }

  let(:work) { Image.new }
  let(:user) { build(:admin_user) }

  it "returns itself" do
    expect(form.object).to eq form
  end
end
