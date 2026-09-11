// Part 2 of a 3-tiered approach to correcting conflicts between
// methods common to Bootstrap and jQuery, specifically:
//   - tooltip (conflict with DataTables)
//   - slider (conflict with jQuery-UI)
// Both of these wreak havoc with the blacklight_range_limit@8.5.0 plugin
// and the graph/slider used. I suspect this might be resolved with an
// update to range_limit < 9.0, but that may involve assets pipeline
// work that I'm not sure Hyrax is set up for (aka: punting this upgrade).
//
// After we load blacklight_range_limit, which requires bootstrap-slider,
// we need to store the latter's .slider method as Hyrax's dependency on
// jQuery-UI will overwrite it.
(function ($) {
  var bootstrapSlider = $.fn.slider;
  $.fn.bsSlider = bootstrapSlider;
})(window.jQuery);