# frozen_string_literal: true
class ReindexJob < ApplicationJob
  def perform
    # clear out RDF labels so that the reindexing will conduct a fresh fetch
    ::RdfLabel.destroy_all
    ::ActiveFedora::Base.reindex_everything
  end
end
