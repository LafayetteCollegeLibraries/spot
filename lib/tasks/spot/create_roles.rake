# frozen_string_literal: true
namespace :spot do
  namespace :roles do
    def create_roles(names)
      return if names.empty?

      names.each do |role|
        entry = Role.find_or_initialize_by(name: role)
        next unless entry.new_record?

        entry.save

        yield entry if block_given?
      end
    end

    desc "creates roles supplied by roles=(comma separated strings)"
    task create: [:environment] do
      roles = (ENV['roles'] || '').split(',').map(&:chomp).reject(&:empty?)
      create_roles(roles) do |role|
        Rails.logger.info "Created new role: #{role.name}"
      end
    end

    desc "creates default roles"
    task default: [:environment] do
      roles = %i[admin]

      create_roles(roles)
    end
  end
end
