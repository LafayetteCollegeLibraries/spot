# changelog

## [2024.1] - 2024-01-30

### updates 🚀
- fcrepo container to 4.7.6 release (#1087)
- transform controlled_properties fields into nested_attributes (#1065)
- treat errors in redirect_controller as :not_found (#1069)
- add support for Google Analytics GA4 (#1091)

### bug fixes 🪲
- explicitly limit recent items display to 6 (#1088, #1094)

### upgrades 📈
- aws-sdk-s3 -> 1.142.0 (#1092, #1097)
- bootsnap -> 1.17.0 (#1098)
- factory_bot_rails -> 6.4.3 (#1099)
- jquery-rails -> 4.6.0 (#1075)
- json-canonicalization -> 0.4.0 (82a8e37)
- okcomputer -> 1.18.5 (#1103)
- pg -> 1.5.4 (#1079)
- puma -> 6.4.0 (#1080)
- rdf-vocab -> 3.2.7 (#1102)
- rsolr -> 2.5.0 (#1076)
- sidekiq-cron -> 1.9.1 (#1077)
- webdrivers -> 5.3.1 (#1104)
- webmock -> 3.19.1 (#1078)


## [2023.2] - 2023-10-30

### Enhancements ✨

- Upgrade Ruby to 2.7.8, Hyrax to 3.6.0, and various gems + code fixes (#997, #1043, #1045, #1049, #1051, #1081)
- Upgrade NodeJS to v20 (#1084)
- Reinstate `/healthcheck` endpoint (#1054)
- Generate "Last Updated" value from ENV when present (#1050, #1061)
- Run `apt-get upgrade` on Fedora and Solr containers to update system dependencies (#1063)

### Bug fixes 🐞

- New collections shouldn't find their way into the homepage's "Recent Works" array (#1062)


## [2023.1.3] - 2023-09-21

more bugfixes and backports while we prepare the 2023.2 upgrade release

- GitHub Actions fixes (d1a41c1, #1057)
- force `Spot::BasePresenter#download_url` to be https:// (#1057)
- configure rails to `force_ssl` (#1057)
- add /healthcheck endpoint (#1054)
- backport reverting back to static error pages (older version of `non-digest-assets` gem) (41616c1, #1053)
- allow error report rendering and controller caching to be toggled via ENV (7590c61, #1066)
- use updated Google Analytics GA4 partial (d38442a, #1068)


## [2023.1.2] - 2023-08-22

### Bug fixes 🐞

- Correct Rails mail configuration for AWS (#1047)


## [2023.1.1] - 2023-08-21

Some last updates for the initial AWS migration.

## updates
- ActionMailer configured to pull SMTP config values from environment (f856ae7561fd80ebb853f515fe65d1d260c119cf)
- `Spot::HandleService` now pulls cert values from the environment, rather than files (19235794fa0e0f5e3e73e8c96728ad232efdf7d3)


## [2023.1] - 2023-07-11

Spot is moving to AWS-based infrastructure and this release is the first pass at getting it running in the cloud. Spot 2.0 if you will! (see #947 for PR)

## Cloud Changes ☁️
- IIIF derivatives are stored in an S3 bucket and accessed via Samvera's [`serverless-iiif`](https://github.com/samvera/serverless-iiif) project
  - Minio (for S3) and Cantaloupe (for IIIF serving) are used for local development
- FCRepo, Handle, and Solr services are now Dockerized locally
- Rails now uses Redis for caching
- Sidekiq service now uses FITS CLI instead of the FITS servlet
- Containers are built using GitHub Actions on demand, pre-release, and release

## Enhancements ✨
- Embargo/release date HTML elements now have a `min="YYYY-MM-DD"` value (today for embargoes, tomorrow for leases), which should prevent accidentally setting a date in the past (#975, @jwellnit)
- Twitter cards now display work thumbnails and descriptive text (Abstract -> Description -> placeholder text) (#983, @jwellnit)
- Browse Collections view per_page limit increased to 12 to improve grid display (#981, @jwellnit)
- About page splash image now includes Alt. Text (#982, @jwellnit)
- `subject_ocm` values are now indexed as full-text (in addition to facets) (#994, @jwellnit)
- Facet added for `advisor`, replacing `organization` (#991, @jwellnit)
- Google Scholar `<meta/>` tags added to work displays (#1005, @jwellnit)

## Bugfixes 🐞
- Replace out of date containers in CircleCI (#972)
- `Hyrax::HasOneTitleValidator` now accepts language-tagged literals as valid titles (#980)
- `Spot::Importers::CSV::WorkTypeMapper` strips spaces from URI values (#987, @jwellnit)
- Date fields now all have hint text specifying YYYY-MM-DD and YYYY-MM formats (#986, @jwellnit)
- Site masthead now has `aria-label` applied (#995, @jwellnit)
- Check WDS last when generating `StudentWork#advisor` label and fall back to storing the email address if the service is unreachable (#1020)
- Use updated query for populating recent works on homepage (#1006)


## [2022.5] - 2022-09-29

### updates ✨
- prioritize CollectionPresenter#abstract for collection descriptions on work views (#950)
- rename "Foreign Languages and Literatures" department to "Languages and Literary Studies" (#954)

### bug fixes 🐞
- setting `work.visibility = "authenticated"` will now result in `work.visibility == "authenticated"`, instead of "metadata" (#951)

### notes 🎶
after deploying to production, you'll want to update all objects in the "Foreign Languages and Literatures" department to use the new name:

```ruby
old_dept = 'Foreign Languages & Literatures'
new_dept = 'Languages and Literary Studies'
ActiveFedora::Base.where(academic_department_sim: [old_dept]).each do |work|
  work.academic_department = work.academic_department.map { |department| department == old_dept ? new_dept : department }
  work.save
end
```


## [2022.4] - 2022-08-01

### updates 📰
- removes solr_suggest autocomplete from StudentWork fields "advisor" and "bibliographic_citation" (#930)
- add Darlingtonia-based service for ingesting objects via CSV sheet (#932, #944)
- add link to accessibility remediation request in footer (#945)
- add `keyword_tesim` and `date_associated_tesim` to all_fields search (see notes) (#946)

### deprecations 💀
- removes BagIt ingest infrastructure used for initial migration (#934)

### bug fixes 🐞
- add catalog_controller configuration to display "advisor_label_ssim" facets properly (#928)
- add permalink display to student_work show page (#927)
- use `String#underscore` to build the parameter key for works in the HandleController (#943)

### notes 📓
- requires a reindex of Image works for `date_associated` fields (see #946)


## [2022.3] - 2022-05-01

### updates
- update workflow specs to ensure that we can handle works with multiple advisors (#900)
- add toggleable student-work banner on homepage (#886)
- add panel to work-edit form that displays `Sipity::Comment`s for the work (#911)
- add text to work#update flash message that reminds user about workflow_actions form, when actions are present (#914)
- ensure faculty ldr user accounts are created when their `lafayette_instructors` authority entry is (#912)
- allow a work's read_users to view a work if it is in an workflow (#917)

### accessibility 💻
- add "aria-label" and "title" attributes to the iiif viewer's iframe (#887)
- add empty alt tags for decorative links (ie thumbnails) (#902)

### bugfixes 🐞
- revert back to rails cookies for sessions (#906)
- loosen up regex on @lafayette emails (#909)
- clean up (and hopefully fix) flaky oai feature spec (#888)

### dependencies 👩‍👧‍👧

- bootsnap to 1.11.1 (#891)
- capistrano to 3.17.0 (#897)
- capistrano-rails to 1.6.2 (#920)
- capybara-screenshot to 1.0.26 (#924)
- devise-guests to 0.8.1 (#893)
- honeybadger to 4.12.1 (#922)
- listen to 3.7.1 (#918)
- okcomputer to 1.18.4 (#896)
- puma to 5.6.4 (#894)
- rails to 5.2.7.1 (#919)
- rspec-rails to 5.1.2  (#921)


## [2022.2] - 2022-03-31

### updates 🔬
- remove LoadLafayetteInstructorAuthorityJob cron instructions until we're ready to go live with the feature (#820)
- remove patches for subject_label and location_label reindex (#821)
- store email addresses in `StudentWork#advisor`, instead of L-numbers (#827)
- workflow updates
  - send emails to users alongside new messages (#822, #837, #838, #840, #848)
  - use locales to display verb-ified labels for actions (#828)
  - validations
    - prevent workflow form from being submitted without an action selected (#828)
    - require workflow actions requesting changes include a comment (#835)
  - remove unused workflow configurations (#842)
  - deposit StudentWork objects into the admin_set using `mediated_student_work_deposit` workflow by default for all users except admins (#843)
  - create a "Student Work" admin_set as part of the db/seed process (#850)
- move Handle identifier minting from the ActorStack to a Hyrax callback (#833)
- remove unused capistrano task relating to #646 (#844)
- put "Add new work" button on top of standard user dashboard (#849)
- use shared `_work_descriptions` partial for all work types (#862)
- use locales for page_titles (#864)
- redirect hyrax's /terms page to our terms-of-use (#864)
- description fields in presenters replace newlines (`/\r?\n/`) with html line breaks (#865)
- store User `#given_name` and `#surname` separately and add `#display_name` and `#authority_name` methods (#871)
- add `:active` flag to Qa::LocalAuthorityEntry (and scope to `active: true`) so that we can retain authority entries that are no longer returned from the WDS API (rather than deleting) (#873)
- use WDS 'PREFERRED_FIRST_NAME' key (where present) in creating labels for instructors (#874)
- add default values for StudentWorkForm when the user is a student (#872)
  - `creator` and `rights_holder` are `current_user.authority_name`
  - `rights_statement` is InC-EDU
- generate `date_available` as part of the object activation step of our workflows (#881)
- upgrade rubies to 2.4.6 (#884)
- move Representative Media form fields to their own tab (#878)

### bugfixes 🐞
- `GrantSipityRoleToAdvisor` needs to provide a `Sipity::WorkflowRole`, not `Sipity::Role` (#818)
- `StudentWorkForm#rights_statement` will now properly display a previously selected value in the dropdown (#826)
- AdminSet#show views now render after adding some guard clauses and using an instance variable within collection views (#830)
- force thumbnails to use sRGB colorspace to prevent bug where some PDF thumbnails were being produced inverted (#832)
- `Spot::BasePresenter`: delegate metadata_only? checks to a`can?(:read, solr_document)` call (#847)

### dependencies 👩‍👩‍👧‍👧
- `devise_cas_authenticatable` to 2.0.2
  - adds db migration to store Sessions via ActiveRecord



## [2022.1] - 2022-01-19

### updates 🛠️
- merge work_type locales into a single file (per language), remove locales we're not currently supporting (#786)
- index controlled vocabulary labels as searchable text as well as strings (#791, #810, #813, #815)
- rubocop updates (#788)
  - use `.robocop_todo.yml` instead of inline disabling
  - no longer indent `private`/`protected` methods rails style
- dev updates (#793)
- add `bibliographic_citation` to `Spot::CoreMetadata` mixin (thanks @noraegloff!!) (#792)
- add `User#lnumber` attribute and determine user roles from CAS authentication entitlement URIs (#783, #797)
- add StudentWork submission Sipity workflow (still experimental! but functional) (#782)

### bug fixes 🐞
- use the string '202110' in `Spot::LoadLafayetteInstructorsAuthorityJob` , instead of dynamically generating one based on the current date (which was causing tests to fail in the new year) (#811)

### dependencies 👩‍👩‍👧‍👧
- bootsnap to 1.9.4 (#812)
- devise to 4.8.1 (#801)
- dotenv-rails to 2.7.6 (#772)
- edtf to 3.0.6 (#781)
- jbuilder to 2.11.5 (#805)
- puma to 4.3.10 (#816)
- kaminari to 1.2.2 (#809)
- rails to 5.2.6 (#776)
- rsolr to 2.4.0 (#802)



## [2021.6] - 2021-12-06

### enhancements 🛠️
- update repository_librarian_email address (abfc7ba)
- add Athletics and College Archives to Lafayette Divisions authority (#751)
- reconfigure Dockerfile + local docker-compose setup (#762, #763, #770)
- add StudentWork model (#753) and switch to using Ability to determine what work types are presented to the user
- add lafayette_instructors local authority endpoint and use it for `StudentWork#advisor` (#764)
- removes broken version number from site footer (#766)
- switches to running rails on port 443 within the container, generating a self-signed ssl certificate as part of the docker entrypoint (#768)
- removes FlipFlop option for contextual search results, leaving them on all the time (#771)
- fixes for a couple of long out-standing "code complexity" issues

### dependencies 👩‍👩‍👧‍👧
- updates hyrax to 2.9.6 and locks down dependencies needed to continue running locally on our on-prem version of ruby (#765).
- bootsnap to 1.9.1 (#760)
- capistrano-bundler to 2.0.1 (#736)
- capistrano-passenger to 0.2.1 (#756)
- faraday to 0.17.4 (#731)
- rubyzip to 2.3.2 (#759)
- uglifier to 4.2.0 (#757)



## [2021.5] - 2021-08-13

### updates
- update email address + links for reproduction requests on About page (thanks @noraegloff!)

### dependencies 👩‍👩‍👧‍👧

- bagit to 0.4.4 (#732)
- capybara-screenshot to 1.0.25 (#735)
- edtf-humanize to 2.0.1 (#737)
- honeybadger to 4.9.0 (#742)
- mini_magick to 4.11.0 (#739)


## [2021.4] - 2021-05-18

### enhancements
- clean up presenters and move common delegation/methods to `Spot::BasePresenter` (#703)
- adds metadata-only visibility option (#704)
- adds a job to sync a Collection's permission_template with its members (#714)
- updates to Docker setup for better local testing (#729)

### features 😎
- add "Board of Trustees" to divisions (#699)

### bug fixes 🐞
- call `CGI.escape` and `CGI.unescape` on OAI setSpec values for valid identifiers (#713)
- `HandleController` and `Spot::RedirectController` will now successfully redirect to Collections with matching identifiers (#726)

### dependencies 👩‍👩‍👧‍👧
- byebug to 11.1.3 (#718)
- capistrano to 3.16.0 (#722)
- carrierwave to 1.3.2 (#697)
- database_cleaner to 2.0.1 (#720)
- jbuilder to 2.11.2 (#710)
- mimemagic to 0.3.10 (#715)
- oauth to 0.5.6 (#716)
- rspec to 3.10.0 (#707)
- spring to 2.1.1 (#719)
- removes `solr_wrapper` and `fcrepo_wrapper` dev dependencies (#724)
- moves Dependabot configuration to v2 config file (#717)


## [2021.3] - 2021-02-05

### enhancements 🔧
- adds a locale for custom language labels (`"iso_639_1.<2 letter code>"`) (#693)
- creates a `Spot::WorksControllerBehavior` mixin for common mixins/behavior (#694)
  - adds .csv handling to `Hyrax::ImagesController`, which was causing a bunch of honeybadger reports
- add "Center for the Integration of Teaching, Learning, and Scholarship" academic department option (#695)

### dependencies 👩‍👩‍👧‍👧
- capistrano to 3.15.0 (#687)
- nokogiri locked at `~> "1.10.10"` until we can upgrade ruby (#688)
- okcomputer to 1.18.2 (#685)
- rails to 5.2.4.4 (#686)
- rspec-rails to 4.0.1 (#684)


## [2021.2] - 2021-01-21

### bug fixes 🐞
- ensure bookmark toggles aren't displayed on _any_ controller (#670)
- point CollectionPresenter to the correct related_resource key (#674)
- add link to LDR submission form on about page (#679)
- add partials for Publication and Image json responses (fixes a "stack level too deep" error that would pop up) (#680)

### features 🧑‍🏭
- split common work-model behavior into `Spot::CoreMetadata` and `Spot::WorkBehavior` mixins (#676)
- catalog_controller updates (#677)
  - facet limit defined globally (rather than per-facet)
  - added OCM Classification facet to sidebar
  - fixed field keys for #index views
  - humanize edtf date values


## [2021.1] - 2021-01-04

### bug fixes 🐞
- add `<link>` tag for favicon (#654)
- use `hyrax/1_column` layout for `Hyrax::PagesController` pages (#667)

### enhancements 💪
- add disallow routes to robots.txt (#652)
- remove blacklight's bookmark feature from routes (#653)
- only conduct passenger capistrano tasks on `:web` servers (#668)
- use `bundle exec rails s` as command for docker-compose main app to allow for better debugging (#669)

### dependencies 👩‍👩‍👧‍👧
- capistrano-rails to 1.6.1 (#666)
- jquery-rails to 4.4.0 (#663)
- shoulda-matchers to 4.4.1 (#665)


## [2020.13] - 2020-12-04

### features ✨
- adds `/collections` landing page, displaying collection branding + summaries (#638)
- note about collections content added to `/about` page (#631)

### dependencies 👩‍👩‍👧‍👧
- capistrano to 3.14.1 (#640)
- hydra-role-management to 1.0.3 (#644)
- rubyzip to 2.3.0 (#641)
- slack-ruby-client to 0.14.6 (#643)


## [2020.12] - 2020-11-20

### updates
- Image batch 5 mappers added (#616)

### bug fixes 🐞
- `ImageForm#date` should not be a required field (#634)

### dependencies 👩‍👩‍👧‍👧
- remove `xray-rails` (#636)


## [2020.11] - 2020-11-10

### features 👩‍🔬
- refactor docker environment for development (#607)
- use authenticated docker pulls for circleci (#615)

### bug fixes 🐞
- ensure that fields are provided when calling OaiCollectionSolrSet.sets_for (#608)
- add resource_type to mammana-postcards mapper (#610)
- use correct subject field for mdl-prints mapper (#611)
- updates missing dashboard (collections/works) translations (#612)

### dependency updates 👩‍👩‍👧‍👧
- honeybadger to 4.7.2 (#626)
- coffee-rails to 5.0.0 (#627)
- sidekiq-cron to 1.2.0 (#628)
- sass-rails to 5.1.0 (#629)
- rails-controller-testing to 1.0.5 (#630)


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

[2024.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2024.1
[2023.2]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2023.2
[2023.1.3]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2023.1.3
[2023.1.2]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2023.1.2
[2023.1.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2023.1.1
[2023.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2023.1
[2022.5]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2022.5
[2022.4]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2022.4
[2022.3]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2022.3
[2022.2]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2022.2
[2022.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2022.1
[2021.6]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2021.6
[2021.5]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2021.5
[2021.4]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2021.4
[2021.3]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2021.3
[2021.2]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2021.2
[2021.1]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2021.1
[2020.13]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.13
[2020.12]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.12
[2020.11]: https://github.com/LafayetteCollegeLibraries/spot/releases/tag/2020.11
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
