spot
====

[![Build Status](https://travis-ci.org/LafayetteCollegeLibraries/spot.svg?branch=master)](https://travis-ci.org/LafayetteCollegeLibraries/spot)
[![Coverage Status](https://coveralls.io/repos/github/LafayetteCollegeLibraries/spot/badge.svg?branch=master)](https://coveralls.io/github/LafayetteCollegeLibraries/spot?branch=master)

:warning: _**this project is under active construction**_ :warning:

Spot is the future Digital Collections and Institutional Repository
for Skillman Library at Lafayette College. It is a [Hyrax]-based
Ruby-on-Rails application.

requirements
------------

- [Solr] version 7.1.0
- [Fedora Commons] digital repository
- [Redis]
- [ImageMagick] - for image derivatives
- [FITS] - for file information
- [LibreOffice] - for document derivatives
- [ffmpeg] - for a/v derivatives / transcoding
- Ruby, version 2.4.2
- Rails, `>= 5.1.4`

installing + starting
---------------------

```
git clone https://github.com/LafayetteCollegeLibraries/spot
cd spot
bundle install
bundle exec rails db:migrate
```

You'll need to have a PostgreSQL database created. See
[the postgres setup guide] in the Spot wiki.

In a separate console tab, `cd /path/to/spot` and start the Fedora + Solr
servers:

```
bundle exec rails spot:dev_server
```

And in yet another, `cd /path/to/spot` and start the Sidekiq server (for
async processing/jobs):

```
bundle exec sidekiq
```

Back in your first console, you'll need to first create the default admin set:

```
bundle exec rails hyrax:default_admin_set:create
```

And then you're good start Spot:

```
bundle exec rails server
```


[Hyrax]: http://hyr.ax/
[Solr]: http://lucene.apache.org/solr/
[Fedora Commons]: http://www.fedora-commons.org/
[Redis]: http://redis.io/
[ImageMagick]: http://www.imagemagick.org/
[FITS]: https://github.com/samvera/hyrax#characterization
[LibreOffice]: https://github.com/samvera/hyrax#derivatives
[ffmpeg]: https://github.com/samvera/hyrax#transcoding
[the postgres setup guide]: https://github.com/LafayetteCollegeLibraries/spot/wiki/Setting-up-PostgreSQL
