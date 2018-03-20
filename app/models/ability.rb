class Ability
  include Hydra::Ability
  include Hyrax::Ability

  self.ability_logic += [:everyone_can_create_most_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    if current_user.admin?
      can %i[create show add_user remove_user index edit update destroy], Role
    end

    if current_user.trustee? || current_user.admin?
      can %i[create discover show update edit destroy], TrusteeDocument
    end
  end

  private

  def blacklisted_models
    [TrusteeDocument]
  end

  def everyone_can_create_most_curation_concerns
    return unless registered_user?
    can :create, curation_concerns_models - blacklisted_models
  end
end
