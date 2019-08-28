# frozen_string_literal: true
class Ability
  include Hydra::Ability
  include Hyrax::Ability

  self.ability_logic += [:depositor_abilities, :admin_abilities]

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
    end

    # Delegates abilities for users that have the 'depositor' role
    # (includes admins)
    #
    # @return [void]
    def depositor_abilities
      return unless current_user.depositor?

      # folks can create new items
      can(:create, curation_concerns_models)

      # can view the user dashboard
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
