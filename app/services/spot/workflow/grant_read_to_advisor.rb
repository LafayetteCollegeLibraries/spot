# frozen_string_literal: true
module Spot
  module Workflow
    # Attaches the advisor's `User#user_key` to the target's #read_users
    class GrantReadToAdvisor
      def self.call(target:, **)
        advisor_lnumber = target.advisor.first.to_s
        advisor_key = case advisor_lnumber
                      when /^L\d{8}$/
                        User.find_by(lnumber: advisor_lnumber).pluck(:user_key)
                      when /^[^@]+@\w+\.\w+$/
                        advisor_lnumber
                      end

        # what do we do if the key is nil?
        target.read_users += [advisor_key]
        ::Hyrax::GrantReadToMembersJob.perform_later(target, advisor_key)
      end
    end
  end
end
