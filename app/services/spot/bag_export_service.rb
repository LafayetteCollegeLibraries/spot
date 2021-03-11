# frozen_string_literal: true
module Spot
  class BagExportService
    attr_reader :work

    def self.identifier_for(work, date: formatted_date)
      new(work).bag_identifier(date: date)
    end

    def self.export(work, to:, gzip: false)
      new(work).export(destination: to, gzip: gzip)
    end

    # @param [SolrDocument, ActiveFedora::Base]
    def initialize(work)
      @work = work
    end

    # @return [String]
    def bag_identifier(date: formatted_date)
      "ldr-#{work.id}-#{date}-#{etag_digest}"
    end

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
        "#{bag_identifier}.tar#{gzip ? '.gz' : ''}"
      end

      # I'd like to leave some flexibility for +@work+ to be either a +SolrDocument+
      # or a descendent of +ActiveFedora::Base+, so we won't assume that a +#file_sets+
      # method exists on the object.
      #
      # @return [Array<FileSet>]
      def file_sets
        @file_sets ||= work.file_set_ids.map { |id| ::FileSet.find(id) }
      end

      # Processes file_set object through +Hyrax::FileSetCSVService+ with our preferred
      # fields and combains headers + values into a single string.
      #
      # @param [FileSet] file_set
      # @return [String]
      def file_set_csv(file_set)
        fields = [:id, :label, :title, :depositor, :creator, :visibility, :format_label, :original_checksum, :etag]
        service = Hyrax::FileSetCSVService.new(file_set, fields)

        [service.csv_header, service.csv].join
      end

      # Wraps up Bag generation by creating a SHA-256 manifest
      #
      # @return [void]
      def finalize_bag
        @bag.manifest!(algo: 'sha256')
      end

      # Today's date formatted YYYYMMDDTHHMMSS
      #
      # @return [String]
      def formatted_date
        Time.zone.now.strftime('%Y%m%dT%H%M%S')
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

      # @return [Zli]
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

      # @return [void]
      def write_files_to_bag
        files_dir = File.join(@bag.data_dir, 'files')
        FileUtils.mkdir_p(files_dir)

        file_sets.map(&:original_file).each do |file|
          # need to write our own +@bag.add_file+ as the BagIt gem doesn't
          # handle binary files so well
          absolute_path = File.join(files_dir, file.file_name.first)

          File.open(absolute_path, 'wb') do |io|
            file.stream.each { |chunk| io << chunk }
          end
        end

        @bag.write_bag_info
      end

      # @return [void]
      def write_metadata_to_bag
        @bag.add_file('metadata.csv') { |io| io.write(Spot::WorkCSVService.for(work)) }

        file_sets.each do |fs|
          @bag.add_file("metadata-#{fs.label}.csv") { |io| io.write(file_set_csv(fs)) }
        end
      end
  end
end
