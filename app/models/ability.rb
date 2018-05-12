class Ability
  include Hydra::Ability
  include Hyrax::Ability

  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    if current_user.admin?
      can %i[create show add_user remove_user index edit update destroy], Role
    end
  end
end
