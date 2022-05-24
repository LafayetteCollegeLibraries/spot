# frozen_string_literal: true
#
# Intended to be used as a replacement for +Hyrax::PresentsAttributes#attribute_to_html+
# (and its associated private methods). This allows us to use our own renderers
# without having to namespace to +Hyrax::Renderers+, though we'll also fall back
# to a super +#renderer_for+ if it exists.
#
# Note that this does not replace any of the other methods defined by the Hyrax
# mixin. It is simply a less-monkey-patchy way of changing the renderer selector.
module Spot
  module PresentsAttributes
    # Identical to +Hyrax::PresentsAttributes#attribute_to_html+, but removes
    # the option of rendering as an HTML <dl>.
    #
    # @param field [Symbol] field to render (must be a method of the presenter)
    # @param options [Hash]
    # @option :render_as [Symbol] use an alternate renderer
    #   (ex. +:faceted+ or +:faceted_attribute+ to use {FacetedAttributeRenderer})
    # @return [String]
    def attribute_to_html(field, options = {})
      unless respond_to?(field)
        Rails.logger.warn("#{self.class} attempted to render #{field}, but no method exists with that name.")
        return
      end

      renderer_for(field, options).new(field, send(field), options).render
    end

    private

    # Determine the renderer based on an option passed. Defaults to
    # {Spot::Renderers::AttributeRenderer}.
    #
    # Copied from https://github.com/samvera/hyrax/blob/v3.0.0-beta1/app/presenters/hyrax/presents_attributes.rb#L63-L69
    #
    # @param _field [Symbol]
    # @param options [Hash]
    # @option :render_as
    # @return [Spot::Renderer, Hyrax::Renderer]
    def renderer_for(_field, options)
      if options[:render_as]
        find_renderer_class(options[:render_as])
      else
        Renderers::AttributeRenderer
      end
    end

    # Combines a Symbol name with one of two suffixes to locate a
    # renderer class. If a super method is present, it will delegate
    # there if no local renderers are found.
    #
    # Copied from https://github.com/samvera/hyrax/blob/v3.0.0-beta1/app/presenters/hyrax/presents_attributes.rb#L48-L61
    #
    # @param name [Symbol]
    # @return [Spot::Renderer, Hyrax::Renderer]
    # @raises [NameError] if renderer not found
    def find_renderer_class(name)
      renderer = nil
      ['Renderer', 'AttributeRenderer'].each do |suffix|
        const_name = "#{name.to_s.camelize}#{suffix}".to_sym
        renderer =
          begin
            Renderers.const_get(const_name)
          rescue NameError
            nil
          end

        break unless renderer.nil?
      end

      return renderer unless renderer.nil?

      # super will check the Hyrax scope, which is necessary for their renderers
      super
    end
  end
end
