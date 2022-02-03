// prevent the workflow-action form from being submitted if no action is selected
$(document).ready(function () {
  $('#workflow_controls form').on('submit', function (ev) {
    var $actionName = $('#workflow_controls form input[name="workflow_action[name]"]:checked').val();

    // submit the form if we have an action to take
    if ($actionName) { return; }

    // stop the submission + insert an alert for the user
    ev.preventDefault();

    var $alert = $('<div class="alert alert-danger" role="alert"></div>')
                 .append('<button type="button" class="close" data-dismiss="alert" aria-label="Close">'
                       +   '<span aria-hidden="true">&times;</span>'
                       + '</button>')
                 .append('Please select an action below');

    $(this).find('.panel-body').prepend($alert);

    return false;
  });
})
