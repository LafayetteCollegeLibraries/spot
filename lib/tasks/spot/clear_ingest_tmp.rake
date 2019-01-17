# frozen_string_literal: true

namespace :spot do
  desc 'clear out tmp/ingest directory. use `[n]` to provide days since (default is 3 days)'
  task :clear_ingest_tmp, [:since] => [:environment] do |_t, args|
    require 'fileutils'

    args.with_defaults(since: '3')

    tmp_dir = Rails.root.join('tmp', 'ingest')
    find_args = ['-type d', '-maxdepth 1']

    find_args.unshift("-ctime +#{args.since}") unless args.since == '*'

    dirs = `find #{tmp_dir} #{find_args.join(' ')}`.split("\n")

    dirs.each do |dir|
      puts "removing tmp/ingest/#{File.basename(dir)}"
      FileUtils.rm_r(dir)
    end
  end
end
