# frozen_string_literal: true
RSpec.describe Ability do
  describe '.preload_roles!' do
    before { Role.destroy_all }

    # this might fail in the future if we change the order in the method
    # (rspec will fail if the changed `.to` array is in a different order)
    it 'creates roles for each CAS entitlement category' do
      expect { described_class.preload_roles! }
        .to change { Role.pluck(:name) }
        .from([])
        .to(
          [
            described_class.admin_group_name,
            described_class.depositor_group_name,
            described_class.alumni_group_name,
            described_class.faculty_group_name,
            described_class.staff_group_name,
            described_class.student_group_name
          ]
        )
    end
  end
end
