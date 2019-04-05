# frozen_string_literal: true
#
# Load all of our overrides/class_evals
# (adapted from https://github.com/sciencehistory/chf-sufia/blob/d1c7d58/config/application.rb#L43-L48)
#
# Trying the +:to_prepare+ callback, rather than +:after_initialization+
# because occasionally the changes (namely class_attribute assignments)
# are forgotten on a reload. This should only run once in production,
# but before each request in development.
Rails.application.config.to_prepare do
  Dir.glob(Rails.root.join('app', 'overrides', '**', '*.rb')) do |c|
    Rails.configuration.cache_classes ? require(c) : load(c)
  end
end
