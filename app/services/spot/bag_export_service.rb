# frozen_string_literal: true
module Spot
  # Service for creating tar'd BagIt directories for works. These are intended to
  # be our preservation copies of items and are laid out as such:
  #
  #   $> tree /path/to/ldr-<work.id>-
  #   |--- bag-info.txt
  #   |--- bagit.txt
  #   |--- data
  #   |    |--- files
  #   |         |--- image-file.png
  #   |    |--- metadata.csv
  #   |    |--- metadata_files.csv
  #   |--- manifest-sha256.txt
  #   |--- tagmanifest-md5.txt
  #   |--- tagmanifest-sha1.txt
  #
  # @example Basic usage
  #   work = Image.find('abc123def')
  #   Spot::BagExportService.export(work, to: Rails.root.join('tmp', 'export'))
  class BagExportService
    attr_reader :work

    # @param [ActiveFedora::Base,SolrDocument] work
    # @param [Hash] options
    # @option [String,Pathname] to
    #   Directory to export work to
    # @option [true, false] gzip
    #   Whether or not to gzip the tar'd bag (default: false)
    def self.export(work, to:, gzip: false)
      new(work).export(destination: to, gzip: gzip)
    end

    # @param [SolrDocument, ActiveFedora::Base] work
    def initialize(work)
      @work = work
    end

    # @return [String]
    def identifier
      "ldr-#{work.id}-#{etag_digest}"
    end

    # @param [Hash] options
    # @option [String,Pathname] destination
    #   Directory to export tar'd work to
    # @option [true, false] gzip
    #   Whether or not to gzip the tar'd bag (default: false)
    # @return [true]
    def export(destination:, gzip: false)
      outpath = File.join(destination, filename_for_bag(gzip: gzip))

      # write bag to file
      prepare_bag do |bag|
        Dir.chdir(bag.bag_dir) do
          Minitar.pack(Dir.glob('./**/*'), output_io(outpath, gzip: gzip))
        end
      end
    end

    private

      # @return [String]
      def etag_digest
        [work, file_sets].flatten.map(&:etag).sort.each_with_object(Digest::SHA1.new) do |etag, digest|
          digest << etag[3..-2]
        end.hexdigest
      end

      # @param [Hash] options
      # @option [true, false] gzip Whether the filename should include '.gz' extension
      #
      # @return [String]
      def filename_for_bag(gzip:)
        "#{identifier}.tar#{gzip ? '.gz' : ''}"
      end

      # I'd like to leave some flexibility for +@work+ to be either a +SolrDocument+
      # or a descendent of +ActiveFedora::Base+, so we won't assume that a +#file_sets+
      # method exists on the object.
      #
      # @return [Array<FileSet>]
      def file_sets
        @file_sets ||= work.file_set_ids.map { |id| ::FileSet.find(id) }
      end

      # Wraps up Bag generation by creating a SHA-256 manifest
      #
      # @return [void]
      def finalize_bag
        @bag.manifest!(algo: 'sha256')
      end

      # Local headers to write to our Bag manifests
      #
      # @return [Hash]
      def local_bag_info
        {
          'Source-Organization' => 'Lafayette College Libraries',
          'Bagging-Date' => Time.zone.now.strftime('%Y-%m-%d'),
          'External-Identifier' => work.id
        }
      end

      # @return [File,Zlib::GzipWriter]
      def output_io(filename, gzip:)
        return File.open(filename, 'wb') unless gzip

        Zlib::GzipWriter.new(File.open(filename, 'wb'))
      end

      # Adds files and metadata csv to the Bag directory (uses a tmp directory)
      # and yields the +BagIt::Bag+ object to be stored someplace.
      #
      # @yield [BagIt::Bag]
      def prepare_bag
        @workdir = Dir.mktmpdir
        @bag = BagIt::Bag.new(File.join(@workdir, work.id), local_bag_info)

        write_metadata_to_bag
        write_files_to_bag
        finalize_bag

        yield @bag

        true
      ensure
        FileUtils.remove_entry(@workdir)
      end

      # @return [Spot::WorkMembersExporter]
      def work_members_exporter
        Spot::WorkMembersExporter.new(work)
      end

      # @return [void]
      def write_files_to_bag
        files_dir = File.join(@bag.data_dir, 'files')
        FileUtils.mkdir_p(files_dir)

        work_members_exporter.each_file do |file|
          absolute_path = File.join(files_dir, file.file_name.first)

          File.open(absolute_path, 'wb') do |io|
            file.stream.each { |chunk| io << chunk }
          end
        end

        @bag.write_bag_info
      end

      # @return [void]
      def write_metadata_to_bag
        @bag.add_file('metadata.csv') { |io| io.write(Spot::WorkCSVService.for(work, include_administrative: true)) }
        @bag.add_file('metadata_files.csv') { |io| io.write(Spot::FileSetCSVService.for(file_sets, include_administrative: true)) }
      end
  end
end
