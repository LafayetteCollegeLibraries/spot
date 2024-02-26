# frozen_string_literal: true

# Register valid OEmbed endpoints
#
# @todo Should we clear out the existing providers so that only ours will apply?
kaltura_provider = OEmbed::Provider.new('http://media.lafayette.edu/oembed')
kaltura_provider << 'https://media.lafayette.edu/id/*'
kaltura_provider << 'https://media.lafayette.edu/media/*'

OEmbed::Providers.register(kaltura_provider)
