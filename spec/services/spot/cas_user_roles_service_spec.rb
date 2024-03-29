# frozen_string_literal: true
RSpec.describe Spot::CasUserRolesService do
  let(:service) { described_class.new(user: user) }
  let(:entitlements) { [staff_uri, faculty_uri] }
  let(:faculty_uri) { 'https://ldr.lafayette.edu/faculty' }
  let(:staff_uri) { 'https://ldr.lafayette.edu/staff' }
  let(:user) { create(:admin_user) }

  describe '.update_roles_from_entitlements' do
    context 'when a user has roles already' do
      it 'retains the non-CAS roles' do
        expect { described_class.update_roles_from_entitlements(user: user, entitlements: entitlements) }
          .to change { user.roles.pluck(:name) }
          .from(['admin', 'depositor'])
          .to(['admin', 'depositor', 'staff', 'faculty'])
      end
    end

    context 'when a users roles do not match entitlements' do
      let(:user) { create(:student_user) }
      let(:entitlements) { ['https://ldr.lafayette.edu/'] }

      it 'modifies role membership to match' do
        expect { described_class.update_roles_from_entitlements(user: user, entitlements: entitlements) }
          .to change { user.roles.pluck(:name) }
          .from(['student'])
          .to([])
      end
    end
  end
end
