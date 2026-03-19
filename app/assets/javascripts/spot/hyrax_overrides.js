// This file is for overriding defaul hyrax js behavior.

$(document).ready(() => {
  if ($('#permissions_error_text').text() === '') {
    $('#permissions_error').attr('hidden', '');
  }

  $('#file-upload-cancel-btn').attr('hidden', '');
  
  $('#fileupload').on('fileuploadstop', () => {
    $('#file-upload-cancel-btn').attr('hidden', '');
  })
});