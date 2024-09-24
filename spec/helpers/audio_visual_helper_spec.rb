# frozen_string_literal: true
RSpec.describe AudioVisualHelper do
  describe '#s3_url' do
    subject { helper.s3_url(key) }

    let(:key) { '1234-0-access.mp3' }
    let(:s3_bucket) { 'av-derivatives' }
    let(:mock_s3_client) { instance_double(Aws::S3::Client) }
    let(:mock_s3_object) { instance_double(Aws::S3::Object) }
    let(:url) { "s3://#{s3_bucket}/#{key}" }
    let(:client_opts) { { endpoint: "http://localhost:9000" } }

    before do
      stub_env('AWS_AV_ASSET_BUCKET', 'av-derivatives')
      allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
      allow(Aws::S3::Object).to receive(:new).with(bucket_name: s3_bucket, key: key, client: mock_s3_client).and_return(mock_s3_object)
      allow(mock_s3_object).to receive(:presigned_url).with(:get, expires_in: 3600).and_return(url)
    end

    context 'the env field does not exist' do
      before do
        stub_env('AWS_ENDPOINT_URL', '')
        allow(Rails.logger).to receive(:warn)
      end

      it 'logs a warning and returns the empty string' do
        expect(helper.s3_url(key)).to eq ""
        expect(Rails.logger).to have_received(:warn)
          .with('AWS_ENDPOINT_URL environment variable is not defined.')
      end
    end

    context 'the env field exists' do
      before do
        stub_env('AWS_ENDPOINT_URL', 'http://minio:9000')
      end

      context 'the object does not exist' do
        before do
          allow(mock_s3_client).to receive(:head_object).with(bucket: 'av-derivatives', key: key).and_raise(Aws::S3::Errors::NotFound.new(nil, nil))
          allow(Rails.logger).to receive(:warn).with('S3: Key not found.')
        end

        it 'logs a warning and returns the empty string' do
          expect(helper.s3_url(key)).to eq ""
          expect(Rails.logger).to have_received(:warn)
            .with('S3: Key not found.')
        end
      end

      context 'the object exists' do
        let(:mock_s3_head) { instance_double(Aws::S3::Types::HeadObjectOutput) }

        before do
          allow(mock_s3_client).to receive(:head_object).with(key: key, bucket: 'av-derivatives').and_return(mock_s3_head)
        end
      
        context 'env is in development' do
          before do
            allow(Rails.env).to receive(:development?).and_return(true)
            allow(Aws::S3::Client).to receive(:new).with(client_opts).and_return(mock_s3_client)
            helper.s3_url(key)
          end

          it 'is expected to receive the client opts' do
            expect(Aws::S3::Client).to have_received(:new).with(client_opts)
          end

          it { is_expected.to eq url }
        end

        context 'env is not in development' do

          before do
            allow(Rails.env).to receive(:development?).and_return(false)
            helper.s3_url(key)
          end

          it 'is not expected to receive the client opts' do
            expect(Aws::S3::Client).to_not receive(:new).with(client_opts)
          end

          it { is_expected.to eq url }
        end
      end
    end
  end

  describe '#get_original_name' do
    subject { get_original_name(presenters, derivative) }

    let(:derivative) { '1234-0-access.mp3' }
    let(:wrong_presenter) { instance_double(Hyrax::FileSetPresenter) }
    let(:right_presenter) { instance_double(Hyrax::FileSetPresenter) }
    let(:right_name) { 'correct_name' }
    let(:wrong_name) { 'wrong_name' }
    let(:right_id) { '1234' }
    let(:wrong_id) { '5678' }

    before do
      allow(wrong_presenter).to receive(:id).and_return(wrong_id)
      allow(wrong_presenter).to receive(:original_filenames).and_return([wrong_name])
      allow(right_presenter).to receive(:id).and_return(right_id)
      allow(right_presenter).to receive(:original_filenames).and_return([right_name])
    end

    context 'the right presenter is included' do
      let(:presenters) { [wrong_presenter, wrong_presenter, right_presenter, wrong_presenter] }

      it { is_expected.to eq right_name }
    end

    context 'the right presenter is not included' do
      let(:presenters) { [wrong_presenter, wrong_presenter, wrong_presenter] }

      it { is_expected.to eq "" }
    end
  end

  describe '#get_derivative_list' do
    subject { get_derivative_list(file_set) }

    let(:file_set) { build(:file_set) }
    let(:work) { instance_double(AudioVisual) }
    let(:derivatives) { ['1234_0_access.mp3', '1234_1_access.mp3'] }

    before do
      allow(file_set).to receive(:parent).and_return(work)
      allow(work).to receive(:stored_derivatives).and_return(derivatives)
    end

    it { is_expected.to match_array derivatives }
  end

  describe '#get_derivative_res' do
    subject { get_derivative_res(derivative) }

    let(:derivative) { '1234_0_access-480.mp4' }

    it { is_expected.to eq '480' }
  end
end
