# frozen_string_literal: true
namespace :spot do
  desc 'Reindexes everything in the repository, fetching new RDF labels'
  task reindex: [:environment] do
    ReindexJob.perform_later
  end
end
