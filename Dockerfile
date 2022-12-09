##
# TARGET: spot-base
# Does the majority of setup for dev/prod images.
##
FROM ruby:2.4.6-alpine3.10 as spot-base

# system dependencies
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
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

ENTRYPOINT ["/spot/bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "ssl://0.0.0.0:443?key=/spot/tmp/ssl/application.key&cert=/spot/tmp/ssl/application.crt"]

HEALTHCHECK CMD curl -skf https://localhost || exit 1

##
# TARGET: spot-development
# Base container for local development. Reruns bundle install for dev gems
##
FROM spot-base as spot-development
ENV RAILS_ENV=development
RUN bundle install --jobs "$(nproc)" --with="development test"
COPY . /spot

##
# TARGET: spot-production
# Precompiles assets for production
##
FROM spot-base as spot-production
ENV RAILS_ENV=production
COPY . /spot
RUN SECRET_KEY_BASE="$(bin/rake secret)" \
    bundle exec rake assets:precompile

##
# TARGET: spot-worker
# Installs dependencies for running background jobs
##
FROM spot-base as spot-worker

ARG FITS_VERSION=1.5.1
ENV FITS_VERSION=${FITS_VERSION}

# @see https://github.com/mperham/sidekiq/wiki/Memory#bloat
ENV MALLOC_ARENA_MAX=2

# We don't need the entrypoint script to generate an SSL cert
# for Sidekiq, as it's not world-readable.
ENV SKIP_SSL_CERT=true

RUN apk --no-cache update && \
    apk --no-cache add \
        bash \
        ffmpeg \
        ghostscript \
        imagemagick \
        libreoffice \
        mediainfo \
        openjdk11-jre \
        perl

# Install FITS
# (from https://github.com/samvera/hyrax/blob/3.x-stable/Dockerfile#L59-L65)
RUN mkdir -p /usr/local/fits && \
    cd /usr/local/fits && \
    wget "https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip" -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /usr/local/fits/fits.sh

ENV PATH="${PATH}:/usr/local/fits"

# Copy last so we can cache the other steps
COPY . /spot

CMD ["bundle", "exec", "sidekiq"]
