# frozen_string_literal: true
namespace :spot do
  namespace :roles do
    def create_roles(names)
      return if names.empty?

      names.each do |role|
        entry = Role.find_or_initialize_by(name: role)

        yield entry if block_given?

        entry.save
      end
    end

    def split_roles_from_env(val)
      (val || '').split(',').map(&:chomp).reject(&:empty?)
    end

    desc 'Adds user to specified roles (provide `user=<email-address>` and `role=<comma-delimited roles>`'
    task add_user_to_role: [:environment] do
      roles = split_roles_from_env(ENV['role'])
      abort 'No roles provided' if roles.empty?

      user_email = ENV.fetch('user')
      user = ::User.find_by(email: user_email)
      abort "No user found with #{user_email}" if user.nil?

      create_roles(roles) do |role|
        role.users << user

        puts "Added #{user} to role #{role.name}."
      end
    end

    desc "creates roles supplied by roles=(comma separated strings)"
    task create: [:environment] do
      roles = split_roles_from_env(ENV['roles'])
      create_roles(roles) do |role|
        Rails.logger.info "Created new role: #{role.name}"
      end
    end

    desc "creates default roles"
    task default: [:environment] do
      names = Ability.preload_roles!.map(&:name)
      puts "Created #{names.count} role#{'s' if names.count != 1}: #{names.join(', ')}"
    end
  end
end
