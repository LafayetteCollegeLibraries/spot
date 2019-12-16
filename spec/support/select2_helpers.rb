# frozen_string_literal: true
module Select2Helpers
  # Fills in a form element containing a Select2 autocomplete widget.
  #
  # @param [String] key
  #   HTML class name of the element (usually '.<work type>_<field camel-cased>')
  # @param [Hash] options
  # @option [String] with Value to be added
  # @see https://stackoverflow.com/a/25047358
  def fill_in_autocomplete(key, with:)
    page.execute_script(%{
      var $input = $('#{key} input.form_control').last();
      $input.val('#{with}');
      $input.trigger('change');
    })
  end
end
