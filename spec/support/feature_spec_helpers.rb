# frozen_string_literal: true
#
# Helper methods for feature specs to construct css selectors for work types and their fields.
# This is particularly necessary during the Valkyrization process as the selector prefixes change
# based on the type of resource being loaded (eg. "publication" vs "publication_resource").
# Included are methods to return just the work prefix.
#
# @example with Hyrax.config.use_valkyrie? == true
#   audio_visual_selector_field('resource_type')
#   #=> "audio_visual_resource_resource_type"
#
# @example with Hyrax.config.use_valkyrie? == false
#   student_work_selector_field('description')
#   #=> "student_work_description"
#
# @example with Hyrax.config.use_valkyrie? == true
#   publication_selector_prefix
#   #=> "publication_resource"
#
# @example with Hyrax.config.use_valkyrie? == false
#   image_selector_prefix
#   #=> "image"
#
module FeatureSpecHelpers
  # @param [Symbol,#to_s] field
  # @return [String]
  def audio_visual_selector_for(field)
    selector_for(field: field, type: :audio_visual)
  end

  # @return [String]
  def audio_visual_selector_prefix
    selector_prefix_for(type: :audio_visual)
  end

  # @param [Symbol,#to_s] field
  # @return [String]
  def image_selector_for(field)
    selector_for(field: field, type: :image)
  end

  # @return [String]
  def image_selector_prefix
    selector_prefix_for(type: :image)
  end

  # @param [Symbol,#to_s] field
  # @return [String]
  def publication_selector_for(field)
    selector_for(field: field, type: :publication)
  end

  # @return [String]
  def publication_selector_prefix
    selector_prefix_for(type: :publication)
  end

  # @param [Symbol,#to_s] field
  # @return [String]
  def student_work_selector_for(field)
    selector_for(field: field, type: :student_work)
  end

  # @return [String]
  def student_work_selector_prefix
    selector_prefix_for(type: :student_work)
  end

  # @option [Symbol,#to_s] field
  # @option [Symbol,#to_s] type
  # @return [String]
  def selector_for(field:, type:)
    "#{selector_prefix_for(type: type)}_#{field}"
  end

  # @option [Symbol,#to_s] type
  # @return [String]
  def selector_prefix_for(type:)
    Hyrax.config.use_valkyrie? ? "#{type}_resource" : type.to_s
  end
end
