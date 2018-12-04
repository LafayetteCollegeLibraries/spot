var Autocomplete = require('hyrax/autocomplete')
var autocomplete = new Autocomplete()

$(document).ready(function () {
  $('.form-group.language_tagged').manage_fields({
    add: function (event, _element) {
      // `add` is called after the element is cloned but before it's added
      // to the DOM, so we need to quick pause for that to happen before
      // initializing the next input
      //
      // note: this is on the roadmap for the 4.x series:
      //       https://github.com/samvera/hydra-editor/issues/158
      window.setTimeout(function () {
        var $target = $(event.currentTarget)
        var $elem = $target.find('[data-autocomplete]').last()

        // cloning an input doesn't remove its value,
        // so we need to do that manually
        // (this causes a brief flash of the previous data
        // but i don't think there's any way around that)
        $elem.parent().parent().find('input').val('')

        autocomplete.setup($elem,
                           $elem.data('autocomplete'),
                           $elem.data('autocompleteUrl'))
      }, 0)
    }
  })
})
