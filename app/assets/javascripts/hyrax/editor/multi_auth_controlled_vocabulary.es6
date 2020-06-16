import ControlledVocabulary from 'hyrax/editor/controlled_vocabulary'

export default class MultiAuthControlledVocabulary extends ControlledVocabulary {
  constructor(element, paramKey) {
    super(element, paramKey);

    // since ControlledVocabulary creates an options object to send to FieldManager,
    // we'll need to update those internal values after initialization (since the
    // former's signature isn't expecting options at the second position, but rather a string)
    this.inputTypeClass = '.multi_auth_controlled_vocabulary';
    this.element.find('select.form-control').on('change', e => this.handleAuthoritySelect(e));
  }

  _newFieldTemplate() {
    let controls = this.controls.clone();
    let placeholder = this.element.find('input.multi-text-field').last().attr('placeholder');
    let $selectElement = this.element.find('select.form-control').last().clone();
    $selectElement.on('change', e => this.handleAuthoritySelect(e));

    let $selectField = $('<div class="col-sm-4"></div>').append($selectElement);
    let $inputs = $(`<div class="col-sm-8">${this._input_template_source({ placeholder: placeholder })}</div>`);
    let $listBody = $('<div class="row"></div>').append($selectField).append($inputs);

    return $('<li class="field-wrapper input-group input-append"></li>').append($listBody).append(controls);
  }

  _input_template_source(opts = {}) {
    let klass = opts.klass || 'controlled_vocabulary';
    let index = opts.index || this._maxIndex();
    let paramKey = opts.paramKey || this.paramKey;
    let name = opts.fieldName || this.fieldName;
    let placeholder = opts.placeholder || '';

    return `
      <input
        class="string ${klass} optional form-control ${paramKey}_${name} form-control multi-text-field"
        data-attribute="${name}"
        id="${paramKey}_${name}_attributes_${index}_hidden_label"
        name="${paramKey}[${name}_attributes][${index}][hidden_label]"
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

  handleAuthoritySelect (event) {
    event.preventDefault();

    let $target = $(event.target);
    let $input = $target.parent().parent().find('input.form-control');
    let authorityPath = $target.val();

    console.log('handleAuthoritySelect: %s', authorityPath);

    $input.data('autocompleteUrl', authorityPath);
    $input.attr('readonly', false);

    autocomplete.setup($input, $input.data('autocomplete'), $input.data('autocompleteUrl'));
  }
}
