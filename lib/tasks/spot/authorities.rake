# frozen_string_literal: true
require_relative '../../../config/boot'
namespace :spot do
  namespace :authorities do
    desc 'Load Instructors from Lafayette database'
    task :load_instructors, [:termcode] => :environment do |_t, args|
      args.with_defaults(termcode: Time.zone.today.strftime('%Y10'))

      Spot::LoadLafayetteInstructorsAuthorityJob.perform_now(term: args.termcode)
    end
  end
end
