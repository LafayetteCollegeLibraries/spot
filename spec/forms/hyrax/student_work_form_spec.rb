# frozen_string_literal: true
RSpec.describe Hyrax::StudentWorkForm do
  it_behaves_like 'a Spot work form'

  it_behaves_like 'it handles required fields', :title, :resource_type, :rights_statement
end
