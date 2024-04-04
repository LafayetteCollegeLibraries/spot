// fills in the findInput search box with the
// provided query term (when present), only on load
document.addEventListener('pagerendered', function (ev) {
  var findInput = document.getElementById('findInput')
  var app = PDFViewerApplication

  app.eventBus.on('pagesloaded', function () {
    var findController = app.findController || {}
    var state = findController.state || {}
    var query = state.query || null

    if (!query) {
      return
    }

    findInput.value = query
  })
})