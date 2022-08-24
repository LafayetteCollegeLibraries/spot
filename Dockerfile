##
# TARGET: spot-base
# Does the majority of setup for dev/prod images.
# Use --build-arg BUNDLE_WITHOUT="" to build with dev dependencies
##
FROM ruby:2.4.6-alpine3.10 as spot-base

# system dependencies
RUN apk --no-cache upgrade && \
    apk --no-cache add \
        build-base \
        coreutils \
        curl \
        git \
        netcat-openbsd \
        nodejs \
        openssl \
        postgresql postgresql-dev \
        ruby-dev \
        tzdata \
        yarn \
        zip

WORKDIR /spot

ENV HYRAX_CACHE_PATH=/spot/tmp/cache \
    HYRAX_DERIVATIVES_PATH=/spot/tmp/derivatives \
    HYRAX_UPLOAD_PATH=/spot/tmp/uploads

# match our Gemfile.lock version
# TODO: upgrade the Gemfile bundler version to 2
RUN gem install bundler:1.13.7

ARG BUNDLE_WITHOUT="development:test"
COPY ["Gemfile", "Gemfile.lock", "package.json", "yarn.lock", "/spot"]
RUN bundle install --jobs "$(nproc)"

COPY . /spot

ENTRYPOINT ["/spot/bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "ssl://0.0.0.0:443?key=/spot/tmp/ssl/application.key&cert=/spot/tmp/ssl/application.crt"]

HEALTHCHECK CMD curl -skf https://localhost || exit 1

##
# TARGET: spot-production
# Precompiles assets for production
##
FROM spot-base as spot-production
ENV RAILS_ENV=production

RUN DATABASE_URL="postgres://fake" \
    SECRET_KEY_BASE="$(bin/rake secret)" \
    bundle exec rake assets:precompile


##
# TARGET: spot-worker
# Installs dependencies for running background jobs
##
FROM spot-base as spot-worker
RUN apk --no-cache upgrade && \
    apk --no-cache add \
        imagemagick \
        ghostscript

# ENV FITS_VERSION=1.5.1
# RUN https://github.com/harvard-lts/fits/releases/download/$FITS_VERSION/fits-$FITS_VERSION.zip

# TODO:
# - install local FITS cli + set ENV for FITS_PATH
# - install open office + set ENV

# RUN bundle config unset --local without && \
    # bundle install --jobs "$(nproc)"

CMD ["bundle", "exec", "sidekiq"]
