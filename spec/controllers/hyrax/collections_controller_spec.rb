# frozen_string_literal: true
RSpec.describe Hyrax::CollectionsController do
  routes { Hyrax::Engine.routes }

  it_behaves_like 'it locates a collection with a slug identifier'
end
