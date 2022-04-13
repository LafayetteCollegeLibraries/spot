# frozen_string_literal: true
module Spot
  module Workflow
    # Attaches the advisor's `User#user_key` to the target's #read_users
    class GrantReadToAdvisor
      def self.call(target:, **)
        return unless target.respond_to?(:advisor)

        advisor_emails = target.advisor.select { |advisor| advisor.end_with?('@lafayette.edu') }
        return if advisor_emails.empty?

        target.read_users += advisor_emails
        advisor_emails.each { |email| ::Hyrax::GrantReadToMembersJob.perform_later(target, email) }
      end
    end
  end
end
