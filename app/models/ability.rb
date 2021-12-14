# frozen_string_literal: true
class Ability
  include Hydra::Ability
  include Hyrax::Ability

  class_attribute :alumni_group_name, default: 'alumni'
  class_attribute :depositor_group_name, default: 'depositor'
  class_attribute :faculty_group_name, default: 'faculty'
  class_attribute :staff_group_name, default: 'staff'
  class_attribute :student_group_name, default: 'student'

  self.ability_logic += [
    :depositor_abilities,
    :admin_abilities,
    :faculty_abilities,
    :student_abilities
  ]

  def self.preload_roles!
    roles = [admin_group_name, depositor_group_name].concat(Spot::CasUserRolesService.group_names_from_cas)
    roles.map { |name| Role.find_or_create_by!(name: name) }
  end

  # Define any customized permissions here.
  #
  # @return [void]
  def custom_permissions; end

  private

  # Delegates abilities for users that have the 'admin' role
  #
  # @return [void]
  def admin_abilities
    return unless current_user.admin?

    can([:create, :delete, :manage], FeaturedCollection)
    can(role_abilities, Role)

    # admins can create everything
    can(:create, curation_concerns_models)
  end

  # Delegates abilities for users that have the 'depositor' role
  # (includes admins)
  #
  # @return [void]
  def depositor_abilities
    return unless current_user.depositor?

    can(:create, Publication)

    # can view the user dashboard
    can(:read, :dashboard)

    # can add items to collections
    can(:deposit, Collection)
  end

  # Delegates abilities for users that have the 'student' role
  #
  # @return [void]
  def faculty_abilities
    return unless current_user.faculty?

    can(:read, :dashboard)
  end

  # Delegates abilities for users that have the 'student' role
  #
  # @return [void]
  def student_abilities
    return unless current_user.student?

    can(:create, StudentWork)
    can(:read, :dashboard)
  end

  # save some space by defining the Role abilities here
  #
  # @return [Array<Symbol>]
  def role_abilities
    %i[
      create
      show
      add_user
      remove_user
      index
      edit
      update
      destroy
      manage
    ]
  end
end
