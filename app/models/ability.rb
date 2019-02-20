# frozen_string_literal: true
class Ability
  include Hydra::Ability
  include Hyrax::Ability

  # @todo restrict this when we have more than one user in here
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  #
  # @return [void]
  def custom_permissions
    if current_user.admin?
      can(role_abilities, Role)
      can([:create, :delete, :manage], FeaturedCollection)
    end
  end

  private

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
