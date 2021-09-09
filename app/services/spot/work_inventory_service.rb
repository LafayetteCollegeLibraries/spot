# frozen_string_literal: true
module Spot
  class WorkInventoryService
    def inventory
      file = File.open(inventory_filename, 'wb')
      @output = Minitar::Output.new(Zlib::GzipWriter.new(file))
      @tar = @output.tar

      work_types.each do |work_type|
        data = StringIO.new
        WorkTypeInventoryService.for(work_type: work_type, io: data)

        @tar.add_file_simple(work_type_filename(work_type), data: data, **inventory_stats)
      end
    ensure
      file.close
    end

    def work_types
      Hyrax.config.registered_curation_concern_types
    end

    private

      def datestamp
        @datestamp ||= Time.zone.now.strftime('%Y%m%d')
      end

      def inventory_filenames
        Rails.root.join('tmp', 'inventories', "ldr-work-inventories-#{datestamp}.tgz").to_s
      end

      def inventory_stats
        { mode: 0o664, ctime: Time.zone.now, mtime: Time.zone.now, uid: Process.uid, gid: Process.gid }
      end

      def work_type_filename(work_type)
        "ldr-inventory-#{work_type}-#{datestamp}.csv"
      end
  end
end
