spot
====

[![Build Status - CircleCI](https://circleci.com/gh/LafayetteCollegeLibraries/spot/tree/primary.svg?style=svg)](https://circleci.com/gh/LafayetteCollegeLibraries/spot/tree/primary)
[![Maintainability](https://api.codeclimate.com/v1/badges/41507959fedd0b4c973f/maintainability)](https://codeclimate.com/github/LafayetteCollegeLibraries/spot/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/41507959fedd0b4c973f/test_coverage)](https://codeclimate.com/github/LafayetteCollegeLibraries/spot/test_coverage)

Spot is the future home of the Lafayette College Digital Repository.
It is a [Hyrax]-based Ruby-on-Rails application. For development we us [Docker Compose],
so setting up an environment on your local machine should be as simple as:

```bash
$ git clone https://github.com/LafayetteCollegeLibraries/spot
$ cd spot
$ docker-compose up -d
$ docker-compose run --rm app bundle exec rails db:migrate
$ docker-compose run --rm app bundle exec rails db:seed
```

and visit `http://localhost:3000` :tada:.

[Hyrax]: https://hyrax.samvera.org
[Docker Compose]: https://docs.docker.com/compose
