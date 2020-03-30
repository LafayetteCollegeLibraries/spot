var Autocomplete = require('hyrax/autocomplete')
var autocomplete = new Autocomplete()

$(document).ready(function () {
  $('.form-control.authority-select').on('change', function () {
    var $this = $(this)
    var authorityPath = $this.val()
    var $input = $this.parent().parent().find('input.form-control')

    $input.data('autocompleteUrl', authorityPath)
    $input.attr('readonly', false)

    autocomplete.setup($input,
                       $input.data('autocomplete'),
                       $input.data('autocompleteUrl'))
  })
})
