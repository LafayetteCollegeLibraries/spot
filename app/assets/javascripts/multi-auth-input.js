// instantiates the multi-auth controlled vocabulary input when we're on the work form.
var MultiAuthControlledVocabulary = require('hyrax/editor/multi_auth_controlled_vocabulary');

$(document).ready(function () {
  // don't bother setting up these additional inputs if there's not a form on the page
  var $formElement = $('[data-behavior="work-form"]');
  if ($formElement.length === 0) { return; }

  // the work-type
  var paramKey = $formElement.data('paramKey');

  $formElement
    .find('.form-group.multi_auth_controlled_vocabulary')
    .each((_idx, field) => {
      console.log('adding multi-auth cv to our field', field)
      return new MultiAuthControlledVocabulary(field, paramKey)
    });
});
