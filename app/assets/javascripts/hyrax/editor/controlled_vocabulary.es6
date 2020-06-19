import { FieldManager } from 'hydra-editor/field_manager'
import Autocomplete from 'hyrax/autocomplete'

export default class ControlledVocabulary extends FieldManager {

  constructor(element, paramKey) {
      let options = {
        /* callback to run after add is called */
        add:    null,
        /* callback to run after remove is called */
        remove: null,

        controlsHtml:      '<span class=\"input-group-btn field-controls\">',
        fieldWrapperClass: '.field-wrapper',
        warningClass:      '.has-warning',
        listClass:         '.listing',
        inputTypeClass:    '.controlled_vocabulary',

        addHtml:           '<button type=\"button\" class=\"btn btn-link add\"><span class=\"glyphicon glyphicon-plus\"></span><span class="controls-add-text"></span></button>',
        addText:           'Add another',

        removeHtml:        '<button type=\"button\" class=\"btn btn-link remove\"><span class=\"glyphicon glyphicon-remove\"></span><span class="controls-remove-text"></span> <span class=\"sr-only\"> previous <span class="controls-field-name-text">field</span></span></button>',
        removeText:         'Remove',

        labelControls:      true,
      }
      super(element, options)
      this.paramKey = paramKey
      this.fieldName = this.element.data('fieldName')
      this.searchUrl = this.element.data('autocompleteUrl')
  }

  // Overrides FieldManager in order to avoid doing a clone of the existing field
  createNewField($activeField) {
      let $newField = this._newFieldTemplate()
      this._addBehaviorsToInput($newField)
      this.element.trigger("managed_field:add", $newField);
      return $newField
  }

  /* This gives the index for the editor */
  _maxIndex() {
      return $(this.fieldWrapperClass, this.element).length
  }

  // Overridden because we always want to permit adding another row
  inputIsEmpty(activeField) {
      return false
  }

  _newFieldTemplate() {
      let index = this._maxIndex()
      let controls = this.controls.clone()//.append(this.remover)
      let row =  $(this.rowTemplate()).append(controls)
      return row
  }

  rowTemplate(opts = {}) {
    let class_name = opts.class || 'controlled_vocabulary';
    let name = opts.name || this.fieldName;
    let index = opts.index || this._maxIndex();
    let paramKey = opts.paramKey || this.paramKey;

    return `
      <li class="field-wrapper input-group input-append">
        <input
          class="string ${class_name} optional form-control ${paramKey}_${name} multi-text-field"
          name="${paramKey}[${name}_attributes][${index}][hidden_label]"
          value=""
          id="${paramKey}_${name}_attributes_${index}_hidden_label"
          data-attribute="${name}"
          type="text" />
        <input
          name="${paramKey}[${name}_attributes][${index}][id]"
          value=""
          id="${paramKey}_${name}_attributes_${index}_id"
          type="hidden"
          data-id="remote" />
        <input
          name="${paramKey}[${name}_attributes][${index}][_destroy]"
          id="${paramKey}_${name}_attributes_${index}__destroy"
          value=""
          data-destroy="true"
          type="hidden" />
      </li>`
  }

  /**
  * @param {jQuery} $newField - The <li> tag
  */
  _addBehaviorsToInput($newField) {
      let $newInput = $('input.multi-text-field', $newField)
      $newInput.focus()
      this.addAutocompleteToEditor($newInput)
      this.element.trigger("managed_field:add", $newInput)
  }

  /**
  * Make new element have autocomplete behavior
  * @param {jQuery} input - The <input type="text"> tag
  */
  addAutocompleteToEditor(input) {
    var autocomplete = new Autocomplete()
    autocomplete.setup(input, this.fieldName, this.searchUrl)
  }

  // Overrides FieldManager
  // Instead of removing the line, we override this method to add a
  // '_destroy' hidden parameter
  removeFromList( event ) {
      event.preventDefault()
      let field = $(event.target).parents(this.fieldWrapperClass)
      field.find('[data-destroy]').val('true')
      field.hide()
      this.element.trigger("managed_field:remove", field)
  }
}
