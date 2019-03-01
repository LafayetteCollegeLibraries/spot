# frozen_string_literal: true
namespace :spot do
  task run_fixity_checks: [:environment] do
    ::Spot::RepositoryFixityCheckJob.perform_later
  end
end
