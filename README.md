spot
====

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
- Ruby, version 2.4.1
- Rails, `>= 5.1.4`

installing + starting
---------------------

```bash
git clone https://github.com/LafayetteCollegeLibraries/spot
cd spot
bundle install
bundle exec rake db:migrate
```

Open up console tabs to run the following commands (in `/path/to/spot`)
concurrently:

1. `fcrepo_wrapper` - to start a test Fedora Repository
2. `solr_wrapper` - to start the Solr engine
3. `bundle exec sidekiq` - use Sidekiq for async jobs


[Hyrax]: http://hyr.ax/
[Solr]: http://lucene.apache.org/solr/
[Fedora Commons]: http://www.fedora-commons.org/
[Redis]: http://redis.io/
[ImageMagick]: http://www.imagemagick.org/
[FITS]: https://github.com/samvera/hyrax#characterization
[LibreOffice]: https://github.com/samvera/hyrax#derivatives
[ffmpeg]: https://github.com/samvera/hyrax#transcoding
