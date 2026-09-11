// Part 3 of a 3-tiered approach to correcting conflicts between
// methods common to Bootstrap and jQuery, specifically:
//   - tooltip (conflict with DataTables)
//   - slider (conflict with jQuery-UI)
// Both of these wreak havoc with the blacklight_range_limit@8.5.0 plugin
// and the graph/slider used. I suspect this might be resolved with an
// update to range_limit < 9.0, but that may involve assets pipeline
// work that I'm not sure Hyrax is set up for (aka: punting this upgrade).
//
// Finally, restore the now-modified tooltip and slider methods to their
// Bootstrap versions and store the jQuery-UI methods separately, just in case.
//
// @note this may raise conflicts down the road if Hyrax is expecting to
//       use jQuery's tooltip or slider interface instead of Bootstrap's?
(function ($) {
  var newTooltip = $.fn.tooltip;
  $.fn.jqTooltip = newTooltip;
  $.fn.tooltip = $.fn.bsTooltip;

  $.fn.jqSlider = $.fn.slider;
  $.fn.slider = $.fn.bsSlider
})(window.jQuery);