# frozen_string_literal: true
#
# Helper methods for feature specs. Most of these are used to construct css selectors for work types
# and their fields.This is particularly necessary during the Valkyrization process as the selector
# prefixes change based on the type of resource being loaded (eg. "publication" vs "publication_resource").
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
#
# Also included is a helper method used to ensure that a passed user is able
# to deposit works into the repository.
module FeatureSpecHelpers
  # Ensures that the provided user is able to deposit into the default admin_set
  #
  # @param [User] user
  # @return [Hyrax::PermissionTemplateAccess]
  def ensure_deposit_access_for(user)
    default_admin_set_id = Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id
    permission_template = Hyrax::PermissionTemplate.find_or_create_by!(source_id: default_admin_set_id)

    Hyrax::PermissionTemplateAccess.find_or_create_by!(
      permission_template: permission_template,
      agent_type: 'user',
      agent_id: user.email,
      access: 'deposit'
    )
  end

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
    type.to_s
    # Hyrax.config.use_valkyrie? ? "#{type}_resource" : type.to_s
  end
end
