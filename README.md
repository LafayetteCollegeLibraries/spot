Spot
====

[![Build Status - CircleCI](https://circleci.com/gh/LafayetteCollegeLibraries/spot/tree/primary.svg?style=svg)](https://circleci.com/gh/LafayetteCollegeLibraries/spot/tree/primary)
[![Maintainability](https://api.codeclimate.com/v1/badges/41507959fedd0b4c973f/maintainability)](https://codeclimate.com/github/LafayetteCollegeLibraries/spot/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/41507959fedd0b4c973f/test_coverage)](https://codeclimate.com/github/LafayetteCollegeLibraries/spot/test_coverage)

**Spot** is the [Hyrax] application powering the [Lafayette College Libraries' Digital Repository (LDR)].

To get started:

```bash
git clone https://github.com/LafayetteCollegeLibraries/spot
cd spot
docker compose build
```

# Development environment

For development, we're using docker compose's [`watch`] functionality
to sync files and restart containers where appropriate. To bring up
the site (and its service dependencies) and watch for changes, run:

```bash
docker compose watch
```

Canned environment variables for development are stored in `.env.development`.
For sensitive values, a `.env.development.local` file is used (an sample file
is provided at the project root: `.env.development.local.sample`).

**Note:** When deploying for the first time, database migrations and seeds will
need to be called with the `db_migrate` service:

```bash
docker compose run --rm db_migrate
```


[Hyrax]: https://hyrax.samvera.org
[Lafayette College Libraries' Digital Repository (LDR)]: https://ldr.lafayette.edu

