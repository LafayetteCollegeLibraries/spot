# frozen_string_literal: true
module Spot::Mappers
  # Mixin to store information about the original image's creation as a note.
  #
  # @example changing the note field (default is "format.digital")
  #   module Spot::Mappers
  #     class LegacyCollectionMapper < BaseMapper
  #       include MapsImageCreationNote
  #
  #       self.image_creation_note_field = 'note'
  #     end
  #   end
  #
  module MapsImageCreationNote
    extend ActiveSupport::Concern

    included do
      class_attribute :image_creation_note_field
      self.image_creation_note_field = 'format.digital'
    end

    # @return [Array<Symbol>]
    def fields
      super + [:note]
    end

    # @return [Array<String>]
    def note
      metadata.fetch(image_creation_note_field, [])
              .map { |s| s.to_s.gsub(/Online display image was converted to JPG format\.$/, '').trim }
    end
  end
end
