# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register "application/n-triples", :nt
Mime::Type.register "application/ld+json", :jsonld
Mime::Type.register "text/turtle", :ttl
Mime::Type.register 'application/x-endnote-refer', :endnote

# Need to define this so that Rack can serve static mjs files appropriately
Rack::Mime::MIME_TYPES['.mjs'] = 'application/javascript'
