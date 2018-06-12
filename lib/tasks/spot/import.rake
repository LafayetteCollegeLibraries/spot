require 'zip'
require 'fileutils'

namespace :spot do
  task try_import_now: :environment do
    IngestZippedBag.new('/Users/malantoa/Documents/ldr-export-20180612/1738.zip').perform
  end
end
