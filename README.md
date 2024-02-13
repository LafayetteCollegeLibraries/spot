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

In a brand new environment, database migrations and seeds will need to be called with the `db_migrate` service:

```bash
docker compose run --rm db_migrate
```

To bring up the site and its service dependencies:

```bash
docker compose up -d
```

To keep files sync'd between this project and the containers, use `docker compose watch`.

[Hyrax]: https://hyrax.samvera.org
[Lafayette College Libraries' Digital Repository (LDR)]: https://ldr.lafayette.edu

