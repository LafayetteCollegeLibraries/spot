# changelog

## [2020.10] - 2020-09-17

### features 🥼 
- add mixin to pass presenter date fields through `edtf-humanize` (#604)

### bug fixes 🐞 
- be more lenient with error handling in original_create_date mapper (#586)
- add `resource_type` to LewisPostcardsMapper (#588), PaKoshitsuMapper (#589), and GeologySlideEsiMapper (#602)
- add `research_assistance` to PaTsubokuraMapper (#596)
- add `subject` to MammanaPostcardsMapper (#603) 
- fix typo for `Image#repository_location` in `_metadata` partial (#601)
- index `Image#source` similarly to `Publication#source` (#601)
- use the right ENV value for IIIF in docker (77ac980)
- translate spaces to underscores in OAI-PMH setSpec identifiers (#606)


## [2020.9] - 2020-08-27

### features 🏖️  
- works added to subcollections will now be added to any parent collections (#561)
- switch to using an external cantaloupe iiif server instead of riiif (#569, #583)
- adds jpg derivative download options to images (#575)
- add mappers for image batch 4 collections (#504)
  - imperial-postcards
  - war-casualties
  - tjwar-postcards

### bug fixes 🐞 
- subclasses Hyrax::IiifManifestPresenter to retain our iiif manifest metadata generation with the new hyrax patterns (#576, #584)
- fixes permission errors that arose from collections not being fetched properly (#585)

### dependencies 👩‍👩‍👧‍👧
- bootsnap to 1.4.7 (#578)
- database_cleaner to 1.8.5 (#579)
- hyrax to 2.9.0 (#573)
- rdf-vocab to 3.1.4 (#581)
- webdrivers to 4.4.1 (#557)
 

## [2020.8] - 2020-07-24

### features 👩‍🔬

- `master` branch has been renamed to `primary`. the old trunk has been locked down to prevent pushes (#538)
- tell webcrawlers to ignore legacy dspace `/bitstream/*` urls (#551)
- install universalviewer via yarn (backported from hyrax@3) (#479)
- updates to mappers
  - `Spot::Mappers::MapsOriginalCreateDate` mixin added, which retains the object's original create_date by storing it in `Image#date_uploaded` (#553, #559)
  - `Spot::Mappers::MapsImageCreationNote` mixin added, which stores information about the original image's creation (stored in `format.digital`) in `Image#note` (#555)
- Image model validations added (#557)
- sort collection members by title by default (#567)

### bug fixes 🐞
- add public fields to Image display (#525)
  - `donor`, `repository_location`, `original_item_extent`, `date_scope_note`
  - fix `related_resource` index field
- quality control fixes for mappers (thanks @noraegloff!)
  - cap (#540)
  - cpw-shashinkai (#542)
  - lewis-postcards (#532)
  - mckelvy-house (#558)
  - pa-omitsu (#566)
  - pacwar-postcards (#562)
  - warner-souvenirs (#537)
  - woodsworth-images (#539)
- add `#permalink` to the image presenter so view pages (+ catalog) will display the url (#564)

### dependencies 👩‍👩‍👧‍👧

- faraday 0.17.3 (#546)
- honeybadger to 4.7.0 (#547)
- hyrax to 2.8.0 (#543)
- listen to 3.2.1 (#548)
- rails to 5.2.4.3 (#544)
- sidekiq to 5.2.9 (#549)
- webmock to 3.8.3 (#545)


## [2020.7] - 2020-06-29

### features 🎁
- adds mappers for image batch 3 collections (#447):
  - cap
  - mckelvy-house
  - mammana-postcards
  - pa-tsubokura
  - mdl-prints
  - geology-slides-esi
- updates capistrano to start/stop sidekiq as a service (recommended for sidekiq @6) (#500)
- adds a multi-authority controlled vocabulary input for `Image#location` (#512)

### bug fixes 🐞
- disable noid minting in specs to circumvent `Ldp::Gone` errors, 🤞 (#487)
- `Spot::Mappers::CpwShashinkaiMapper` will map titles that aren't prefixed with an identifier (ex. `[ts0001] The Monopoly Bureau at Taihoku (Outside of South Gate)`) to `title_alternative`
- make sure edtf dates are created in a valid order (earliest is first) (#508)
- allow different edtf types for `date_sort_dtsi` (#509)
- `Spot::ControlledVocabularies::Location` will fetch labels for URIs other than just GeoNames (#514)
- `rights_statement` values stored as `RDF::URI` objects will render correctly in the work-edit form (#518)
  - `Spot::Actors::BaseActor` has been modified to ensure that we're always storing those values as `RDF::URI` objects
- `subject` edit partial now includes a `wrapper_html` attribute, so new rows have will initialize the Autocomplete fields (#520)

### dependency updates 👩‍👩‍👧‍👧
- blacklight to 6.23.0 (#515)
- capybara to 3.32.1 (#484)
- iso-639 to 0.3.5 (#486)
- kaminari to 1.2.1 (#494, done on master but rebased to this version)
- pg to 1.2.3 (#485)
- puma to 3.12.6 (#492)
- riiif to 2.3.0 (#497)
- websocket-extensions to 0.1.5 (#505)

## [2020.6] - 2020-04-30

### updates ⛰
- use `URL_HOST` environment variable for slack fixity notifications, falling back to `hostname` (#460)
- add location to image iiif manifest (#463)
- add `research_assistance` to image display view (#472)

### bug fixes 🐞
- use subject labels for image iiif manifests (#463)
- eradicate collections during tests to prevent `Ldp::Gone` errors (#470)
- restrict guest accounts to a single db entry (#469)
- use single quotes when adding html to simple_form hints to allow links to render properly in tooltips (#471)
- collection_form now strips whitespace from all strings (#474)
- Image#resource_type now indexes as `_tesim` and `_sim`, similarly to Publication (#475)
- logging in from an Image show page will no longer redirect back to the item's iiif manifest (#477)
- date values with matching start/end values are mapped to the single value (rather than `1930/1930`) (#480)
- w/ eaic collections, map rights_statement values from either `rights.digital` or `rights.statement` (#481)


## [2020.5] - 2020-04-06

### features 🏔
- specify ruby version in `.ruby-version` file (#457)
- use vm version bundler as canon (rather than more-up-to-date one on system/circleci) (#457)

### bug fixes 🐞
- `Spot::Derivatives::AccessMasterService` uses the first layer of the object to generate access copies (using the entirety of large TIFFs was causing our local ImageMagick to hang) (#442)
- fixes `Spot::Forms::CollectionForm` which broke after the work form changes of #407 (#445, #446)
- updates image batch 1 + 2 mappers to include islandora_urls as identifiers (#451)
- force http scheme for islandora `uri:` identifiers (via mapper) (#453)
- ensure `/redirect?url=` values are transformed to http (uses the same technique as #453) (#456)

### dependency updates 👩‍👩‍👧‍👧
- almond-rails to 0.3.0 (#438)
- byebug to 11.1.1 (#436)
- capistrano-sidekiq to 1.0.3 (#454)
- capybara-screenshot to 1.0.24 (#455)
- darlingtonia to 3.2.2 (#437)
- honeybadger to 4.5.6 (#439)
- okcomputer to 1.18.1 (#435)


## [2020.4] - 2020-03-10

### features 🔬
- adds a `ReindexJob` and includes a rake task (`spot:reindex`) (#410)
- adds mappers for Image batch 2 collections (#405)
  - lewis-postcards
  - gc-iroha01
  - pa-koshitsu
  - pa-omitsu01
  - pa-omitsu02
  - pa-omitsu03
  - cpw-shashinkai
- adds a form for Image objects (blocked by #415 for items with "Manchuria" as a location value) (#407)

### bug fixes 🐞
- fixes a typo in the footer (614e197)
- uses brackets when titling an item 'Untitled' (affects the alsace-images mapper) (13ae9cf)
- updates circle-ci config to use password for posgres image (previously blank one now breaks the image) (#408)
- adds indexing for the `rights_holder` property on Publications (#411)

### dependency updates 👩‍👧‍👧
- **hyrax to 2.7.0** (#425)
- capybara to 3.31.0 (#427)
- database_cleaner to 1.8.3 (#428)
- hydra-role-management to 1.0.2 (#417)
- jbuilder to 2.10.0 (#431)
- mini_magick to 4.10.1 (#419)
- nokogiri to 1.10.8 (#412)
- pg to 1.2.2 (#429)
- puma to 3.12.4 (#413, #422)
- rdf-vocab to 3.1.2 (#426)
- rsolr to 2.3.0 (#418)
- spring to 2.1.0 (#424)
- turbolinks to 5.2.1 (#433)
- webmock to 3.8.2 (#416)


## [2020.3] - 2020-02-04

### features ⛱

- creates mappers for the first batch of Image collections to be migrated (#387, #398, #401)
  - alsace-images
  - cpw-nofuko
  - pacwar-postcards
  - rjw-stereo
  - warner-souvenirs
  - woodsworth-images
- uses the locally-generated access derivatives for serving images via RIIIF (#393)
- update Collections#show view form to search `/catalog` instead of showing the results in Collections#show (#400)
- adds metadata fields to display on IIIF manifest (#398)

### bug fixes 🐞

- adds a migration to revert single_use_keys column headers from their hyrax@3 snake_casing to hyrax@2's camelCasing (#395)
- use the correct search_field for publication's location display field (7988b26)
- moves departments that were incorrectly classified as Divisions to the Academic Departments authority (#399)
- sort `representative_files` by their basenames to ensure fronts of postcards are used as the primary image to display (#398)


## [2020.2] - 2020-01-23

### features ❄️
- adds Handle minting service and mints new identifiers during the create cycle (#269)
- adds `rights_holder` to work metadata view (#391)


## [2020.1] - 2020-01-21

### features 🏔
- adds **Women's, Gender & Sexuality** to department authority (#382)
- adds display of embargo/lease information to the item view page (#381)
- adds rights_holder field to Publication form (#385)
- refactors ingest pipeline to use `Spot::BagIngestService` rather than putting all of the work in a job (#386)
- adds disallow rules for `/catalog`, `/catalog/*`, and `/downloads` in robots.txt (#389)

### bug fixes 🐞
- embargo/lease releasing service now changes items to their expected visibilities after the embargo/lease period is up (#381)

### deprecations 💀
- removes `development` and `localhost` capistrano environments (#390)


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

### bug fixes 🐞

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

[2020.10]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.10
[2020.9]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.9
[2020.8]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.8
[2020.7]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.7
[2020.6]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.6
[2020.5]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.5
[2020.4]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.4
[2020.3]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.3
[2020.2]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.2
[2020.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.1
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
