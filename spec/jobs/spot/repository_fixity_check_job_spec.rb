# frozen_string_literal: true
RSpec.describe Spot::RepositoryFixityCheckJob do
  let(:service_double) { instance_double(Hyrax::FileSetFixityCheckService) }
  let(:fs) { instance_double(FileSet, id: 'abc123') }
  let(:job_opts) { {} }

  before do
    allow(Hyrax::FileSetFixityCheckService).to receive(:new).with(fs, **fixity_opts).and_return(service_double)
    allow(service_double).to receive(:fixity_check)
    allow(FileSet).to receive(:find_each).and_yield(fs)

    described_class.perform_now(**job_opts)
  end

  context 'default implementation' do
    let(:fixity_opts) { { async_jobs: false } }

    it 'calls the Hyrax::FileSetFixityCheckService without async_jobs' do
      expect(service_double).to have_received(:fixity_check).at_least(1).times
    end
  end

  context 'with force: true' do
    let(:fixity_opts) { { async_jobs: false, max_days_between_fixity_checks: -1 } }
    let(:job_opts) { { force: true } }

    it do
      expect(service_double).to have_received(:fixity_check).at_least(1).times
    end
  end
end
