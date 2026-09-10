// Browse Everything uses the method call '$(this).button('loading');'
// which is deprecated in Bootstrap 4. This patch returns that functionality.
//
// @see https://stackoverflow.com/questions/48240011/show-loading-using-jquery-in-bootstrap-4-with-data-loading-text
(function($) {
  const bsDeprecatedButton = function(action) {
    if (this.length > 0) {
      this.each(function(){
        if (action === 'loading' && $(this).data('loading-text')) {
          $(this).data('original-text', $(this).html()).html($(this).data('loading-text')).prop('disabled', true);
        } else if (action === 'reset' && $(this).data('original-text')) {
          $(this).html($(this).data('original-text')).prop('disabled', false);
        }
      });
    }
  };
  $.fn.jqButton = $.fn.button;
  $.fn.button = bsDeprecatedButton;
}(window.jQuery));