# frozen_string_literal: true
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# @note we need to require logger manually until concurrent-ruby (a dependency of the DRY
#       library that powers Valkyrie) is updated (might be a while, since DRY has been
#       pinned to ~> 1 for quite a bit). necessary because ruby no longer includes 'logger'
#       as part of the stdlib in Ruby > 3.
require 'logger'

require 'bootsnap/setup' # Load our app faster w/ Bootsnap
