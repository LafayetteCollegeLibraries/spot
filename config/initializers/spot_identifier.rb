# frozen_string_literal: true
#
# This is where we "register" our "standard" prefixes for identifiers.
# Instead of relying on these values being hardcoded into app/models/spot/identifier.rb,
# we can control them here.
%w[doi hdl isbn issn].each { |prefix| Spot::Identifier.register_prefix(prefix) }
