// fills in the findInput search box with the
// provided query term (when present), only on load
document.addEventListener('pagerendered', function (ev) {
  var findInput = document.getElementById('findInput')
  var app = PDFViewerApplication

  app.eventBus.on('pagesloaded', function () {
    var findController = app.findController || {}
    console.log("findController: " + findController)
    var state = findController.state || {}
    console.log("state: " + state)
    var query = state.query || null
    console.log("query: " + query)

    if (!query) {
      return
    }

    findInput.value = query
  })
})