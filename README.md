spot
====

Spot is the codebase for the [Lafayette College Digital Repository]. It is a Ruby on Rails application
using the [Samvera] community's [Hyrax] engine to interact with a [Fedora Commons Repository] and
[Apache Solr] index. The Rails code is also used on a separately running [Sidekiq]-based jobs service.

## Dependencies

<dl>
  <dt><a href="https://fedorarepository.org/">Fedora Commons Repository</a></dt>
  <dd>Main data and asset store. Customized Docker image found at
    <a href="https://github.com/LafayetteCollegeLibraries/spot/tree/primary/docker/fcrepo">docker/fcrepo</a>.</dd>

  <dt><a href="https://solr.apache.org/">Apache Solr</a></dt>
  <dd>Search engine interface for Fedora repository, also used for permissions. Customized Docker image
    found at <a href="https://github.com/LafayetteCollegeLibraries/spot/tree/primary/docker/solr">docker/solr</a>.</dd>

  <dt><a href="https://www.postgresql.org/">PostgreSQL</a></dt>
  <dd>Database for Rails application.</dd>

  <dt><a href="https://redis.io">Redis</a></dt>
  <dd>Used as cache and job queue.</dd>

  <dt><a href="https://github.com/harvard-lts/FITSservlet">FITS Servlet</a></dt>
  <dd>Java servlet wrapper around FITS, used by jobs server for file characterization.
      Customized Docker image found at
      <a href="https://github.com/LafayetteCollegeLibraries/spot/tree/primary/docker/fits_servlet">docker/fits_servlet</a>.</dd>

  <dt><a href="https://github.com/samvera/serverless-iiif">Serverless IIIF</a></dt>
  <dd><a href="https://iiif.io">IIIF</a> image server hosted as an AWS Lambda application.</dd>

  <dt><a href="https://aws.amazon.com/s3/">S3</a></dt>
  <dd>Storage for IIIF derivatives and used for batch ingest</dd>
</dl>

## Setup / Development

Local development is orchestrated using [Docker Compose] (>= 2.23.0), with S3 and Serverless IIIF services replicated
using [MinIO] and [Cantaloupe] respectively. Note: as this application requires nine separate services to
be running simultaneously, local development will be quite resource intensive.

Some setup is required before a successful first launch. Copy `development.local.env.sample` to `development.local.env`
and add values to the following variables:

key                | value
-------------------|-----------
`APPLICATION_FQDN` | hostname for the local dev application; since we use Lafayette's CAS authentication system, this needs to be a domain registered with ITS. Spoof the host locally by adding `127.0.0.1     example.lafayette.edu` to your `/etc/hosts` file.
`CAS_BASE_URL`     | Lafayette CAS server to use for authentication
`DEV_ADMIN_USERS`  | comma-separated list of email addresses to create as admins accounts


### Starting the services

```bash
$ docker-compose up -d --build
```

Startup will run a disposable service, called `db_migrate` which will initialize and seed the application and test
databases, as well as create system defaults and the specified `DEV_ADMIN_USERS`.


### Sidekiq Environment

For adding custom environment variables to the Sidekiq service, add a `development.local.sidekiq.env` file
to the root of the repository. This will be used by Docker Compose, and prioritized over `development.local.env`
if it exists.




[Apache Solr]: https://solr.apache.org/
[Cantaloupe]: https://cantaloupe-project.github.io/
[Docker Compose]: https://docs.docker.com/compose
[Fedora Commons Repository]: https://fedorarepository.org/
[Hyrax]: https://hyrax.samvera.org
[Lafayette College Digital Repository]: https://ldr.lafayette.edu
[MinIO]: https://min.io
[Samvera]: https://samvera.org
[Sidekiq]: https://sidekiq.org/
[docker/fcrepo]: docker/fcrepo
[docker/fits_servlet]: docker/fits_servlet
[docker/solr]: docker/solr