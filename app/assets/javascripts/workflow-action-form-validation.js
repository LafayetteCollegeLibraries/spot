// some basic validations for the workflow_controls form
$(document).ready(function () {
  $('#workflow_controls form').on('submit', function (ev) {
    // close out any previous errors
    $('.workflow-action-validation-error').alert('close');

    // these workflow_actions require comments
    var workflowActionsRequiringComments = [
      'advisor_requests_changes',
      'library_requests_changes',
    ];
    var actionName = $('#workflow_controls form input[name="workflow_action[name]"]:checked').val();
    var requiresComment = workflowActionsRequiringComments.indexOf(actionName) > -1;
    var comment = $('#workflow_action_comment').val().trim();
    var alertText;

    // an action has been provided, let's validate whether or not it needs a comment as well
    if (actionName) {
      // no comments required OR comments are required and one is present,
      // break out of this function to submit the form
      if (!requiresComment || (requiresComment && comment)) { return; }

      // otherwise we need a comment, so we'll display the alert
      else { alertText = 'Please provide a comment about what changes are desired.'; }
    }

    // no action has been provided, we need one
    else {
      alertText = 'Please select an action below.';
    }

    // stop the submission + insert an alert for the user
    ev.preventDefault();

    var $alert = $('<div class="alert alert-danger workflow-action-validation-error" role="alert"></div>')
                 .append('<button type="button" class="close" data-dismiss="alert" aria-label="Close">'
                       +   '<span aria-hidden="true">&times;</span>'
                       + '</button>')
                 .append(alertText);

    $(this).find('.panel-body').prepend($alert);

    return false;
  });
})
