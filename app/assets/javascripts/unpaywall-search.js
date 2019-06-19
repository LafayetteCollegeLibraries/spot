// sends a request to our unpaywall_search controller
// and inserts the returned values into the form
//
// todo:
//   - files don't actually get attached
//     - how does browse-everything do it?
//   - error handling!
//   - success handling!
//   - clean up the ui
$(document).on('ready', function () {
  var $unpaywallForm = $('.import-from-unpaywall')
  var $pubForm = $('#new_publication')

  if ($unpaywallForm.length === 0) return

  $unpaywallForm.find('button').on('click', function (ev) {
    var doi = $unpaywallForm.find('input').val().trim()
    var identifiers = [{prefix: 'doi', value: doi}]

    $.getJSON('/unpaywall_search', { doi: doi }, function (data) {
      // handle errors first
      if (data.error) {
        // put something about how there was a problem
        return
      }

      if (data.creator) {
        [].concat(data.creator).forEach(function (creator) {
          updateFormMetadata('creator', creator)
        })
      }

      if (data.date_issued) {
        updateFormMetadata('date_issued', data.date_issued, { single: true })
        $('input[name="publication[date_issued]"]').last().val(data.date_issued)
      }

      if (data.download_url) {
        var scrubbedName = doi.replace(/\./, '-').replace(/\//, '_') + '.pdf'

        // create the form params
        ;[
          $('<input type="hidden" name="publication[selected_files][unpaywall][0][url]" value="' + data.download_url + '" />'),
          $('<input type="hidden" name="publication[selected_files][unpaywall][0][file_name]" value="' + scrubbedName + '" />'),
        ].forEach(function (el) { $pubForm.append(el) })
      }

      if (data.journal_name) {
        updateFormMetadata('source', data.journal_name)
      }

      if (data.publisher) {
        updateFormMetadata('publisher', data.publisher)
      }

      if (data.rights_statement) {
        updateFormMetadata('rights_statement', data.rights_statement, { single: true })
      }

      if (data.title) {
        updateFormMetadata('title_value', data.title, { single: true })
      }

      if (data.issn) {
        identifiers.push({prefix: 'issn', value: data.issn})
      }

      identifiers.forEach(function (id) {
        // skip the click for the first value
        updateFormMetadata('identifier_prefix', id.prefix, { skipClick: true })
        updateFormMetadata('identifier_value', id.value)
      })
    })
  })

  function updateFormMetadata(key, value, opts) {
    if (!opts) {
      opts = {}
    }

    var mdSelector, btnSelector;

    if (opts.single) {
      mdSelector = 'input[name="publication[' + key + ']"]'
    else {
      mdSelector = 'input[name="publication[' + key + '][]"]'
    }

    $(mdSelector).last().val(value)

    if (!opts.single && !opts.skipClick) {
      btnSelector = opts.btnSelector || '.publication_' + key + ' .btn.add'
      $(btnSelector).trigger('click')
    }
  }
})

