# frozen_string_literal: true
#
# Uses our own CollectionPresenter, which itself is a subclass of the Hyrax one
Hyrax::CollectionsController.class_eval do
  self.presenter_class = Spot::CollectionPresenter
end
