# frozen_string_literal: true
#
# Where possible, we'll try to use the class_attributes provided by the
# various Hyrax pieces to provide our own functionality. However, this
# isn't always possible, and we need to either copy files locally to
# modify or peak into the classes via +class_eval+. Where the latter
# case is necessary, we'll put the file into +app/overrides+ and load
# all of them here, after initialization.
Rails.application.config.after_initialize do

  # Load all of our overrides/class_evals
  # (adapted from https://github.com/sciencehistory/chf-sufia/blob/d1c7d58/config/application.rb#L43-L48)
  Dir.glob(Rails.root.join('app', 'overrides', '**', '*.rb')) do |c|
    Rails.configuration.cache_classes ? require(c) : load(c)
  end
end
