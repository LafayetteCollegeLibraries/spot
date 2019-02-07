# frozen_string_literal: true
require 'bagit'
require 'fileutils'
require 'tmpdir'

RSpec.describe Spot::Validators::BagValidator do
  let(:validator) { described_class.new(error_stream: error_stream) }

  let(:error_stream) { File.open(File::NULL, 'w') }
  let(:parser) { instance_double('Spot::Importers::Bag::Parser') }
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:bag) { fixtures_path.join('sample-bag') }

  before do
    allow(parser).to receive(:file).and_return(bag)
  end

  describe '#validate' do
    subject { validator.validate(parser: parser) }

    context 'when bag does not exist' do
      let(:bag) { '/does/not/exist' }

      it { is_expected.not_to be_empty }
      it { is_expected.to include 'Bag does not exist' }
    end

    context 'when bag is not a directory' do
      let(:bag) { fixtures_path.join('zip-test-fixture.zip') }

      it { is_expected.not_to be_empty }
      it { is_expected.to include 'Bag is not a directory' }
    end

    # rubocop:disable RSpec/InstanceVariable
    #
    # NOTE: this will unfortunately write to STDOUT even though we're
    #       using File::NULL for our error stream. the BagIt gem itself
    #       creates a STDOUT logger within its validity checker
    #       (see: https://github.com/tipr/bagit/blob/c6be043/lib/bagit/valid.rb#L23)
    #       so we're stuck seeing an error in our test output
    context 'when bag is invalid' do
      # s/o to https://stackoverflow.com/a/17512070
      #    and https://github.com/tipr/bagit/blob/c6be043/spec/validation_spec.rb
      before do
        @tmpdir = Dir.mktmpdir
        @bag = BagIt::Bag.new(@tmpdir)
        4.times do |n|
          @bag.add_file("file-#{n}") { |io| io.puts "a new file! ##{n}" }
        end
        @bag.manifest!
        File.open(File.join(@tmpdir, 'data', 'cool-beans'), 'w') do |f|
          f.puts 'nope this one isnt here'
        end

        # have to redefine this here in order to use the instance variable
        # (calling +let(:bag) { @tmpdir }+ returns nil because that runs before
        # the before block does)
        allow(parser).to receive(:file).and_return(@tmpdir)
      end

      after { FileUtils.remove_entry_secure @tmpdir }

      it { is_expected.not_to be_empty }
    end
    # rubocop:enable RSpec/InstanceVariable

    context 'when bag is valid' do
      it { is_expected.to be_empty }
    end
  end
end
