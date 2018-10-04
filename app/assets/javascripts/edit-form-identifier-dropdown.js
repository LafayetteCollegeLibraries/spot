// the html order of the identifier dropdown is:
//
//   <div class="input-group-btn">
//     <button (etc)>...</button>
//     <ul class="dropdown-menu">...</ul>
//     <input type="hidden" />
//   </div>
$(document).ready(function () {
  $('.identifier-prefix-select').click(function (ev) {
    ev.preventDefault()

    // the <a> that was clicked to trigger a select
    var $target = $(ev.target)
    var targetLabelValue = $target.text().trim()
    var targetValue = ev.target.dataset.prefix
    var $listItem = $target.parent()

    // the <ul> that received the event
    var $dropdown = $(ev.delegateTarget)
    var $siblings = $dropdown.siblings()
    var $toggleBtn = $siblings.first()
    var $prefixInput = $siblings.last()
    var currentValue = $prefixInput.val()

    // click the selected value to remove it
    if (targetValue === currentValue) {
      $listItem.removeClass('active')
      return setButtonAndInputValue()
    }

    // clear out all of the active items (should only be one)
    $dropdown.children().each(function (_, child) {
      child.classList.remove('active')
    })

    $listItem.addClass('active')
    setButtonAndInputValue(targetLabelValue, targetValue)

    function setButtonAndInputValue(label, value) {
      if (!label) {
        label = 'Select type'
      }

      if (!value) {
        value = ''
      }

      $toggleBtn.html(label + ' <span class="caret"></span>')
      $prefixInput.val(value)
    }
  })

})
