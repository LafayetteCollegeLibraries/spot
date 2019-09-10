# frozen_string_literal: true

RSpec.describe Hyrax::ImagePresenter do
  skip 'wait for image factory' do
    it_behaves_like 'a spot presenter'
  end
end
