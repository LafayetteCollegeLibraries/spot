namespace :spot do
  namespace :roles do
    desc "creates roles supplied by roles=(comma separated strings)"
    task :create => :environment do
      roles = (ENV['roles'] || '').split(',').map(&:chomp).reject(&:empty?)
      
      return if roles.empty?

      roles.each do |role|
        entry = Role.find_or_initialize_by(name: role)
        next unless entry.new_record?

        entry.save
        puts "Created new role: #{role}"
      end
    end
  end
end