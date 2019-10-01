# changelog

## [2019.1-pre.6] - 2019-10-01

- add `/redirect?url=<digital.laf url>` routing for legacy URLs (#277)
- the hyrax 2nd navbar has returned (#278)
- improvements in collection-slug behavior (`SolrDocument#to_param` now checks if the item is a collection) (#278)
- Collection views now display related_resource URLs below the abstract + description blocks
- changes the download button on a work's show page to be for the primary object download (`/downloads/<work id>`) and moves the zip-export to the dropdown (#291)
- adds several subcollections from dspace content (#292)

fixes:

- use the file_watcher in development that will work with docker
- (collections_from_config) only update when a collection has changed (#276)
- labels in catalog_controller.rb are now symbols, rather than calls to I18n.translate which were encountering issues with engine locales not being loaded when called (#285)


## [2019.1-pre.5] - 2019-09-16

- adds docker configuration for local development
- indexes and displays (when present) handle.net permalinks
  on both the catalog + work-show views
- splits up standard and local identifiers in the work form
  (merged behind the scenes into the single :identifier property)
- adds patch for devise vulnerability (CVE-2019-16109)
- uses `CollectionBrandingInfo (role="logo")`, where applicable,
  for collection thumbnails
- adds implements slugs for collections, but does not require them.
  both `CollectionsController` and `Hyrax::Dashboard::CollectionsController`
  should now be able to account for both slugs and ids.
- adds fields to Collection#show views; removes badges
- changes `Spot::CollectionFromConfig#create` to `#create_or_update!` which
  will update metadata to match that in config/collections.yml on each invocation.

## [2019.1-pre.4] - 2019-08-28

- updates dependencies
- updates to permission handling
  - adds a depositor role
  - limits creation to depositor and admin roles only
  - hides the dashboard from users who aren't able to deposit
- rewrite Image derivative processing
- add rake task for generating derivatives

## [2019.1-pre.3] - 2019-08-20

- add mounted storage to the whitelisted ingest directories
- update how the SPOT_VERSION constant is defined in deployed environments (#248)
- use bar (`|`) as the default multi_value_character for ingest jobs (#250)
- remove capistrano ingest task (never used)
- add separate ingest task for publications (#251)
- use different favicons for the different deployment environments (#252)
- add an admin facet for `visibility_ssi` (#253)
- update newspaper, magazine, and shakespeare mappers to ingest present digital.lafayette.edu URLs (#249)
- add jpeg compression to access_master creation (#254)
- fix nokogiri vulnerability by bumping to v1.10.4 (#255)
- bugfix: use UV 2.0.1, as Hyrax is expecting to find those files

## [2019.1-pre.2] - 2019-08-05

- update a work's `document.title` to resemble '{work title} // Lafayette Digital Repository'
- add text content to the About page
- add link to the Contact page in site footer
- specify Sidekiq concurrency via capistrano-sidekiq configuration
- use the `:ingest` queue for Hyrax's "ingest-like jobs"
- add 'spot:collections:list' task
- bugfix: don't skip single `dc:date` values when mapping to `date_issued` for magazines
- bugfix: add `tmp/uploads` to capistrano's shared directories
- bugfix: assign roles (via capistrano) on the :web server only

## [2019.1-pre.1] - 2019-07-24

Initial pre-release (live on ldr.stage.lafayette.edu)

[2019.1-pre.5]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.5
[2019.1-pre.4]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.4
[2019.1-pre.3]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.3
[2019.1-pre.2]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.2
[2019.1-pre.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.1
