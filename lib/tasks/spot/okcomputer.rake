# frozen_string_literal: true
#
# Run OkComputer checks + print to STDOUT
namespace :spot do
  task status: :environment do
    puts
    puts 'Running system checks'
    puts '---------------------'

    checks = OkComputer::Registry.all
    checks.run

    checks.collection.each_value do |check|
      printf "%-25s %-6s %s\n",
             check.registrant_name,
             check.success? ? 'OK' : 'FAIL',
             check.message
    end
  end
end
