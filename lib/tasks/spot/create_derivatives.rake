# frozen_string_literal: true
namespace :spot do
  desc 'Create derivatives for a file_set (ex: `bundle exec rails spot:create_derivatives[abc123def]`)'
  task :create_derivatives, [:id] => [:environment] do |_t, args|
    abort 'Need to pass an ID!' unless args[:id]
    begin
      file_set = FileSet.find(args[:id])
      file_set.files.each do |file|
        puts "Creating derivatives for file (#{file.id})"
        CreateDerivativesJob.perform_now(file_set, file.id)
      end
    rescue ActiveFedora::ObjectNotFoundError
      abort "FileSet with ID (#{args[:id]}) does not exist"
    end
  end
end
