# changelog

## [2019.9] - 2019-12-20

### features 🎉

- adds suggestions from solr to the following fields (#370, #378):
  - bibliographic_citation
  - contributor
  - creator
  - editor
  - keyword
  - organization
  - physical_medium
  - publisher
  - source
- adds Image metadata model and creates a base indexer and presenter using shared properties (#258)
- reorders PublicationForm fields to conform with suggestions (#375)

### bugfixes 🐞

- fix typo in `rights_statement.yml` authority file (#374)

### dependencies 👩‍👩‍👧‍👧

- updates rack to 2.0.8 (thanks @dependabot! #376)
  - see https://github.com/advisories/GHSA-hrqr-hxpp-chr3

### notes 🗒

- will require updating Solr config files and reindexing for the suggestions and new date-sort field (as well as correcting the the rights_statement typo bug)

### issues affected 🔧

- closes #359
- closes #373


## [2019.8] - 2019-12-06

### features ☃️

- add OAI-PMH support via the blacklight-oai gem (#323)
- index an item's application url if a handle identifier isn't present (part of #323)
- strip leading/trailing whitespace in publication form values (#365)
- adds faceting by rights_statement (using shortcode values) (#366)
- makes Collection slugs readonly after entry (to help prevent unintended changes) (d9af51c)
- redirect users back to the page they were currently at after signing in (#369)

### bug fixes 🐞

- revert part of #350 to allow date_issued to accept YYYY formatting (03a2f9b)
- add "International Affairs" to the department local authority (8fdd907)
- invalid UTF-8 errors during characterization should finally be cleared (#363)
- when releasing embargo, only set date_available if the item contains that property (7b8fdf6)
- fix typo for Periodical resource_type (de1b540)

### dependencies 👩‍👩‍👧‍👧

- adds blacklight-oai gem (#323)
- upgrades puma to 3.12.2 (#368, thanks @dependabot!)

### notes 🗒

- this will require a re-index to support the added fields from #323 and #366


## [2019.7] - 2019-11-25

### features 🦃

- update `robots.txt` file to block archive.org from crawling our works as we don't want to fill up our diskspace quota with access copies of materials (a657879)
- index + store local/standard identifiers in the solr index  ~rather than relying on a presenter to split them out~ (#347)
- display rights-statement label next to icon (6dfe8f2)
- add enhancements to the Publication model (#350)
  - add model validation for `date_issued`, `resource_type`, and `rights_statement`
  - `date_issued`, `resource_type`, and `rights_statement` are now required fields on the form
    - per metadata application profile
  - add formatting clarification to `date_issued` help text (requires YYYY-MM or YYYY-MM-DD)
  - use OCLC's FAST subject headings as a controlled vocabulary for `subject`
- adds a service/job to clear expired embargoes + leases; schedules it nightly using `sidekiq-cron` (#355)
- adds a Publication's `date_available` via the `PublicationActor`, instead of the form. takes into account embargoes when present (#356)

### dependencies 👩‍👩‍👧‍👧

- update PDF.js to latest stable version (2.2.228) which better renders PDFs that were previously getting garbled (#346)
- explicitly add `linkeddata` gem to allow integration of OCLC's FAST subject heading service (#350)

### bug fixes 🐞

- use correct FITSServlet URL in `docker-compose.yml` and `config/initializers/okcomputer.rb` (cd75393)

### deprecations ☠️

- remove `Spot::CollectionFromConfig` service to prevent inadvertently changing live collections (#354)
- remove `date_available` from `PublicationForm` (#356)


## [2019.6] - 2019-11-13

### bug fixes 🐞

- uses the `image-url` scss function for the hashed asset path for a spinner gif (#340)
- updates the `lafayette_departments` local authority file to use the departments defined in the publication metadata profile (#341)
- adds `location_attributes` to the PublicationForm's permitted parameters array (#337)

## [2019.5] - 2019-11-11

### bug fixes 🐞

- update `Hyrax::PublicationForm` to allow `{0,n}` values (#333)
- have `ErrorController` handle `txt` and `json` formats in a really basic manner (#335)

## [2019.4] - 2019-11-10

### features

- adds title_sort_si field to Publication and Collection Solr documents and adds the sort option to the catalog_controller.rb (#328)

### bug fixes 🐞

- use the browse_collections_link in featured collection portion of the homepage (#325)
- use the correct hyrax layout in the contact form (previously was displaying w/o navbar) (#324)
- update the resource_type local authority to match what's listed on the metadata application profile (#326)

### notes 🗒

because of the added solr field, this will require a reindexing.

## [2019.3] - 2019-11-04

### features

- updates newspaper + magazine mappers (#315)
  - better handling of missing values
  - add newspaper mapper handling of 'Easton, PA' for location value (as in accruals)
- removes Spot::RemoteCharacterizationService in favor of using the samvera-based fits-servlet tools (#317)
  - also encodes FITS output into UTF-8 to prevent invalid character errors (see #314)

### bug fixes 🐞

- date_issued and system_create sort field labels were on the wrong field (see #319)
- if an ingest user wasn't already an admin (or the default user), works would not be added to collections
  - by default, users do not have the ability to deposit to collections

## [2019.2] - 2019-10-29

Addresses two vulnerabilities (thanks GitHub!): [CVE-2019-16892](https://nvd.nist.gov/vuln/detail/CVE-2019-16892) and [CVE-2019-16676](https://nvd.nist.gov/vuln/detail/CVE-2019-16676)

- updates rubyzip to 1.3.0 (#310)
- updates hyrax to 2.6.0 (#311), which in turn updates simpleform (source of CVE-2019-16676)

## [2019.1] - 2019-10-28

- adds Honeybadger integration for 500 error pages (#303)
- disables solr's suggestion `buildOnCommit` setting to prevent sluggish writes
  and decrease ingest time
- whitelist the root capistrano directory for ingest files
- update readme

## [2019.1-pre.7] - 2019-10-17

- adds deployment configuration for production (#261)
- uses /ldr base for fedora (#261)
- moves fixity/deposit info on file_sets to an admin-only view (#295)
- stops seeding collections in production environments
- adds terms of use page (#287)
- adds bare-bones 404 and 500 error pages (#301)
- use env variable to provide google analytics id (#302)
- index (+ store) extracted-text content at the work level instead of the file_set (#298)
- adds content for the help page (#304)


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

[2019.9]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.9
[2019.8]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.8
[2019.7]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.7
[2019.6]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.6
[2019.5]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.5
[2019.4]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.4
[2019.3]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.3
[2019.2]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.2
[2019.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1
[2019.1-pre.7]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.7
[2019.1-pre.6]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.6
[2019.1-pre.5]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.5
[2019.1-pre.4]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.4
[2019.1-pre.3]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.3
[2019.1-pre.2]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.2
[2019.1-pre.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2019.1-pre.1
