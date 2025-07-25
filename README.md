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
  <dd>Storage for audio/visual and IIIF derivatives. Also used for batch ingest.</dd>
</dl>

## Setup / Development

Local development is orchestrated using [Docker Compose] (>= 2.23.0), with S3 and Serverless IIIF services replicated
using [MinIO] and [Cantaloupe] respectively. Note: as this application requires nine separate services to
be running simultaneously, local development will be quite resource intensive.

Some setup is required before a successful first launch. While most of the necessary environment variables
can be found in `development.env`, there are a few variables we don't want to commit to the repository.
Define these variables in `development.local.env` and they'll also be included in the container. Use the
[`development.local.env.sample`](./development.local.env.sample) file as a base to add the following
required values:

key                | value
-------------------|-----------
`APPLICATION_FQDN` | hostname for the local dev application; since we use Lafayette's CAS authentication system, this needs to be a domain registered with ITS. Spoof the host locally by adding `127.0.0.1     example.lafayette.edu` to your `/etc/hosts` file.
`CAS_BASE_URL`     | Lafayette CAS server to use for authentication. (Contact ITS for the right URL to use.)
`DEV_ADMIN_USERS`  | comma-separated list of email addresses to create as admins accounts

Also included in the sample local file are Rails variables to use for testing outgoing e-mail messaging (again,
contact ITS for these values).

### Sidekiq Environment

For adding custom uncomitted environment variables to the Sidekiq service, a `development.local.sidekiq.env` file
is prioritized over the general one. This is useful for adjusting log levels between the Rails services.


### Starting the services

```bash
$ docker-compose up -d --build
```

Startup will run a disposable service, called `db_migrate` which will initialize and seed the application and test
databases, as well as create system defaults and the specified `DEV_ADMIN_USERS`.


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