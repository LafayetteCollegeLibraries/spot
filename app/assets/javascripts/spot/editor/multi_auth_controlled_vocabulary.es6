import ControlledVocabulary from 'hyrax/editor/controlled_vocabulary';
import Autocomplete from 'hyrax/autocomplete';

export default class MultiAuthControlledVocabulary extends ControlledVocabulary {
  constructor(element, paramKey) {
    super(element, paramKey);

    // since ControlledVocabulary creates an options object to send to FieldManager,
    // we'll need to update those internal values after initialization (since the
    // former's signature isn't expecting options at the second position, but rather a string)
    this.inputTypeClass = '.multi_auth_controlled_vocabulary';
    this.element.find('select.form-control').on('change', e => this.handleAuthoritySelect(e));
  }

  // replaces the same method in ControlledVocabulary, but avoids using Handlebars
  // to compile a template (see +_input_template_source+). builds out the field to
  // look like what's produced with +MultiAuthorityControlledVocabularyInput#build_field+
  _newFieldTemplate() {
    var controls = this.controls.clone();
    var placeholder = this.element.find('input.multi-text-field').attr('placeholder');
    var $selectElement = this.element.find('select.form-control').last().clone();
    $selectElement.on('change', e => this.handleAuthoritySelect(e));

    var $selectField = $('<div class="col-sm-4"></div>').append($selectElement);
    var $inputs = $(`<div class="col-sm-8">${this._input_template_source({ placeholder: placeholder })}</div>`);
    var $listBody = $('<div class="row"></div>').append($selectField).append($inputs);

    return $('<li class="field-wrapper input-group input-append"></li>').append($listBody).append(controls);
  }

  // we don't need Mustache to compile a template, especially when we're writing
  // these methods/classes in es6. there are a few options you can pass to this,
  // but only +placeholder+ isn't able to be pulled from various class methods/properties.
  _input_template_source(opts = {}) {
    var klass = opts.klass || 'controlled_vocabulary';
    var index = opts.index || this._maxIndex();
    var paramKey = opts.paramKey || this.paramKey;
    var name = opts.fieldName || this.fieldName;
    var placeholder = opts.placeholder || '';

    return `
      <input
        class="string ${klass} optional form-control ${paramKey}_${name} multi-text-field"
        data-autocomplete="${name}"
        id="${paramKey}_${name}_attributes_${index}_hidden_label"
        name="${paramKey}[${name}_attributes][${index}][hidden_label]"
        placeholder="${placeholder}"
        readonly="readonly"
        type="text"
        value="" />
      <input
        data-id="remote"
        id="${paramKey}_${name}_attributes_${index}_id"
        name="${paramKey}[${name}_attributes][${index}][id]"
        type="hidden"
        value="" />
      <input
        data-destroy="true"
        id="${paramKey}_${name}_attributes_${index}__destroy"
        name="${paramKey}[${name}_attributes][${index}][_destroy]"
        type="hidden"
        value="" />`;
  }

  // making this a no-op, as we're initializing the autocomplete _after_ the autority
  // selection is made (if we were to try to do so when the new row is completed, we'd
  // be missing the "data-autocomplete-url" property which is kind of important for autocompleting)
  _addAutocompleteToEditor (input) {}

  // event handler for when the select box changes. sets the "data-autocomplete-url"
  // property of the nearby input + initializes the autocomplete for it. essentially
  // the same functionality provided by the AuthoritySelect class but doesn't use
  // mutation observers which completely locked up my browser when i tried implementing it.
  handleAuthoritySelect (event) {
    event.preventDefault();

    var $target = $(event.currentTarget);
    var $input = $target.parent().parent().find('input.form-control');
    var authorityPath = $target.val();
    var autocomplete = new Autocomplete();

    $input.data('autocompleteUrl', authorityPath);
    $input.val(''); // zero-out an existing value
    $input.attr('readonly', false);

    autocomplete.setup($input, $input.data('autocomplete'), $input.data('autocompleteUrl'));
  }
}
