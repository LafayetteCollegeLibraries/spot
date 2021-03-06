# frozen_string_literal: true
#
# instead of using a helper class for this info, let's follow
# data curation experts' lead and store debug/git info as constants
# that can be accessed within the views.
#
# copied from:
#   https://curationexperts.github.io/playbook/every_project/git_sha.html
module Spot
  LAST_DEPLOYED = begin
    revisions_logfile = '/var/www/spot/revisions.log'

    if Rails.env.production? && File.exist?(revisions_logfile)
      deployed = `tail -1 #{revisions_logfile}`.chomp.split(' ')[7]
      Date.parse(deployed).strftime('%d %B %Y')
    else
      'Not in deployed environment'
    end
  end

  # since capistrano deploys using just the files and
  # not the actual repository, we can't use git (at the
  # application root) to determine the version. instead,
  # there's now a capistrano task (`spot:write_version_file`)
  # that will generate a VERSION file at the release root
  # and we'll read from that. otherwise, assume we're
  # local + run the git command.
  VERSION = begin
    file_path = Rails.root.join('VERSION')

    if File.exist?(file_path)
      File.read(file_path).chomp
    elsif (gittag = `git describe --tags 2> /dev/null`.chomp)
      gittag
    else
      require 'datetime'
      "#{DateTime.current.year}-dev"
    end
  end
end
