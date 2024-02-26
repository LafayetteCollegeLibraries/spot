# frozen_string_literal: true
module Spot
  class ImportOembedThumbnailJob < ::ApplicationJob
    delegate :file_set_actor_class, :ingest_remote_files_service_class, to: Hyrax::Actors::CreateWithRemoteFilesActor

    # @todo This needs some refactoring TLC
    def perform(work:, user_id: nil)
      # this will bail for unapplicable work types and objects without embed_urls
      return if work.try(:embed_url).blank?

      oembed_data = OEmbed::Providers.get(work.embed_url.first)
      return if oembed_data.try(:thumbnail_url).blank?

      user = nil
      user = User.find(user_id) if user_id.present?

      # i'm not crazy about this fwiw?
      file_name = File.basename(oembed_data.thumbnail_url)
      file_name = 'thumbnail.jpg' if File.extname(file_name).blank?

      # zero out thumbnail_id so that CreateWithRemoteFilesJob will use the remote thumbnail
      work.thumbnail_id = nil

      attributes = { remote_files: [{ url: oembed_data.thumbnail_url, file_name: file_name }] }
      env = Hyrax::Actors::Environment.new(work, Ability.new(user), attributes)
      thumbnail_actor_stack.create(env)
    end

    private

    def thumbnail_actor_stack
      Hyrax::Actors::CreateWithRemoteFilesActor.new(Hyrax::Actors::Terminator.new)
    end
  end
end
