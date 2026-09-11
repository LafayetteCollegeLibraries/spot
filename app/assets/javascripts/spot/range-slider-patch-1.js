// Part 1 of a 3-tiered approach to correcting conflicts between
// methods common to Bootstrap and jQuery, specifically:
//   - tooltip (conflict with DataTables)
//   - slider (conflict with jQuery-UI)
// Both of these wreak havoc with the blacklight_range_limit@8.5.0 plugin
// and the graph/slider used. I suspect this might be resolved with an
// update to range_limit < 9.0, but that may involve assets pipeline
// work that I'm not sure Hyrax is set up for (aka: punting this upgrade).
//
// Hyrax has a dependency on jQuery-UI which defines a tooltip method that
// conflicts with Bootstrap's, so we'll store the Bootstrap method under
// a different name and restore it after requiring Hyrax.
(function ($) {
  var bsTooltip = $.fn.tooltip
  $.fn.bsTooltip = bsTooltip;
})(window.jQuery)