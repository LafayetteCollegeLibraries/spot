# frozen_string_literal: true
RSpec.describe Spot::RepositoryFixityCheckJob do
  subject(:perform_job!) { described_class.perform_now(job_opts) }

  let(:service_double) { instance_double(Hyrax::FileSetFixityCheckService) }
  let(:fs) { FileSet.create! }
  let(:job_opts) { {} }

  before do
    allow(Hyrax::FileSetFixityCheckService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:fixity_check)
    fs
  end

  after { FileSet.destroy_all }

  context 'default implementation' do
    let(:opts) { { async_jobs: false } }

    it 'calls the Hyrax::FileSetFixityCheckService without async_jobs' do
      perform_job!

      expect(Hyrax::FileSetFixityCheckService)
        .to have_received(:new)
        .with(fs, opts)

      expect(service_double).to have_received(:fixity_check)
    end
  end

  context 'with force: true' do
    let(:opts) { { async_jobs: false, max_days_between_fixity_checks: -1 } }
    let(:job_opts) { { force: true } }

    it do
      perform_job!

      expect(Hyrax::FileSetFixityCheckService)
        .to have_received(:new)
        .with(fs, opts)

      expect(service_double).to have_received(:fixity_check)
    end
  end
end
