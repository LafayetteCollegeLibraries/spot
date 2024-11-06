# frozen_string_literal: true
RSpec.describe StudentWorkResourceForm, valkyrization: true do
  subject(:form) { described_class.new(resource) }
  let(:resource) { build(:student_work_resource) }
end
