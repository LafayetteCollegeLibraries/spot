# frozen_string_literal: true
#
# Since we've altered the properites of Collections,
# we'll need to provide our own form (which is a subclass
# of the Hyrax one).
Hyrax::Dashboard::CollectionsController.class_eval do
  self.form_class = Spot::Forms::CollectionForm
end
