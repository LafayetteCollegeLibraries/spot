##
# TARGET: spot-base
# !! This is a builder image. Not for general use !!
# Use this as the base image for the Rails / Sidekiq services.
##
FROM ruby:2.4.6-alpine3.10 as spot-base

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

# @todo upgrade the Gemfile bundler version to 2 to remove version constraint
RUN gem install bundler:1.13.7

ARG BUNDLE_WITHOUT="development:test"
COPY ["Gemfile", "Gemfile.lock", "/spot/"]
RUN bundle install --jobs "$(nproc)"

ENTRYPOINT ["/spot/bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "ssl://0.0.0.0:443?key=/spot/tmp/ssl/application.key&cert=/spot/tmp/ssl/application.crt"]

HEALTHCHECK CMD curl -skf https://localhost || exit 1


##
#  Target: spot-asset-builder
#  !! This is a builder image, do not use !!
##
FROM spot-base as spot-asset-builder
ENV RAILS_ENV=production
COPY . /spot
RUN SECRET_KEY_BASE="$(bin/rake secret)" \
    bundle exec rake assets:precompile


##
# TARGET: spot-development
# Base container for local development. Reruns bundle install for dev gems
##
FROM spot-base as spot-development
ENV RAILS_ENV=development

# install awscli the hard way (via python) bc our base image is
# too old to include it in the alpine 3.10 apk
#
# @ see https://gist.github.com/gmoon/3800dd80498d242c4c6137860fe410fd
RUN apk --no-cache --update add musl-dev gcc python3 python3-dev \
    && python3 -m ensurepip --upgrade \
    && pip3 install --upgrade pip \
    && pip3 install --upgrade awscli \
    && pip3 uninstall --yes pip \
    && apk del python3-dev gcc musl-dev

RUN bundle install --jobs "$(nproc)" --with="development test"
COPY . /spot


##
# TARGET: spot-production
# Precompiles assets for production
##
FROM spot-base as spot-production
ENV RAILS_ENV=production
COPY . /spot
COPY --from=spot-asset-builder /spot/public/assets /spot/public/assets
COPY --from=spot-asset-builder /spot/public/uv /spot/public/uv


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

# (from https://github.com/samvera/hyrax/blob/3.x-stable/Dockerfile#L59-L65)
RUN mkdir -p /usr/local/fits && \
    cd /usr/local/fits && \
    wget "https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip" -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /usr/local/fits/fits.sh

ENV PATH="${PATH}:/usr/local/fits"

COPY . /spot
CMD ["bundle", "exec", "sidekiq"]
EXPOSE 3000


##
# Target: spot-worker-production
# Copies compiled assets for use in production.
##
FROM spot-worker as spot-worker-production
ENV RAILS_ENV=production
COPY --from=spot-asset-builder /spot/public /spot/public
