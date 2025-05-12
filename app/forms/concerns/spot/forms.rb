# frozen_string_literal: true
module Spot
  module Forms
    extend ActiveSupport::Autoload

    autoload :BatchEditFormTermsAndPermittedParams
    autoload :ControlledVocabularyFormFields
    autoload :IdentifierFormFields
    autoload :LanguageTaggedFormFields
    autoload :ResourceFormBehavior
  end
end
