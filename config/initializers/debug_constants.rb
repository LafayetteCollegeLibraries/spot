# frozen_string_literal: true
#
# instead of using a helper class for this info, let's follow
# data curation experts' lead and store debug/git info as constants
# that can be accessed within the views.
#
# copied from:
#   https://curationexperts.github.io/playbook/every_project/git_sha.html

revisions_logfile = '/var/www/spot/revisions.log'

GIT_SHA =
  if Rails.env.production? && File.exist?(revisions_logfile)
    `tail -1 #{revisions_logfile}`.chomp.split(' ')[3].gsub(/\)$/, '')
  elsif Rails.env.development? || Rails.env.test?
    `git rev-parse HEAD`.chomp
  else
    nil
  end

GIT_BRANCH =
  if Rails.env.production? && File.exist?(revisions_logfile)
    `tail -1 #{revisions_logfile}`.chomp.split(' ')[1]
  elsif Rails.env.development? || Rails.env.test?
    `git rev-parse --abbrev-ref HEAD`.chomp
  else
    nil
  end

LAST_DEPLOYED =
  if Rails.env.production? && File.exist?(revisions_logfile)
    deployed = `tail -1 #{revisions_logfile}`.chomp.split(' ')[7]
    Date.parse(deployed).strftime('%d %B %Y')
  else
    'Not in deployed environment'
  end
