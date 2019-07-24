# frozen_string_literal: true
#
# This may not be the best way to approach overloads, but I was running
# into issues with a +to_prepare+ block which changed these attributes
# causing a lot of strange locale translation misses. I did _a lot_ of
# poking around and I think I've got it nailed down.
#
# Providing a +to_prepare+ block to the Configuration class adds it to
# an array of blocks called +.to_prepare_blocks+ which is what is iterated
# through when loading (see: https://github.com/rails/rails/blob/v5.1.7/railties/lib/rails/railtie/configuration.rb#L77-L81
# and https://github.com/rails/rails/blob/v5.1.7/railties/lib/rails/application/finisher.rb#L52-L56).
# (note: the code changes in later rails versions, but the concept is the same).
#
# Something about setting one of these class attributes throws a wrench in
# the i18n load path, or something. When they're out, no problem, but we
# want them in. Finding the above code, it seems like what might be happening
# is our +to_prepare+ block is coming before one that loads I18ns from the
# Hyrax engine (or another dependency) and hecking up something.
#
# SO, what this does is:
#   a) loads the overrides in a lambda
#   b) calls that lambda in the +after_initialize+ block
#   c) (when in development) adds the lambda to the _end_ of the
#      +.to_prepare_blocks+ array, so that the next time the +to_prepare+
#      blocks are called, it'll be the last one.
#
# It feels like overkill, but it's the only solution
# that's consistently worked so far.
#
# Please change if you can figure it out!

load_overrides = lambda do
  Hyrax::Dashboard::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::Dashboard::CollectionsController.form_class = Spot::Forms::CollectionForm

  Hyrax::CollectionsController.presenter_class = Spot::CollectionPresenter

  Hyrax::DerivativeService.services = [Hyrax::FileSetDerivativesService, Spot::FileSetAccessMasterService]

  # We've dropped the navbar + banner image that come with Hyrax, and the
  # 'homepage' layout that the PagesController calls defines content for
  # this block. By switching to the 'hyrax' layout (which we're using for
  # the homepage + others), we can drop this component.
  #
  # @todo is there a better way to do this?
  Hyrax::PagesController.class_eval do
    private

      # @return [String]
      def pages_layout
        action_name == 'show' ? 'hyrax' : 'hyrax/dashboard'
      end
  end

  # see above
  Hyrax::ContactFormController.class_eval { layout 'hyrax' }
end

Rails.application.config.after_initialize do
  # load our overrides
  load_overrides.call

  # add the lambda to the blocks run by to_prepare
  #   if we're in development mode
  Rails.application.config.to_prepare_blocks << load_overrides if Rails.env.development?
end
